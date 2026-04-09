"""
SeqTrack-style causal decoder head for SGLATrack (search tokens -> discrete bbox sequence).
Adapted from Microsoft SeqTrack (VideoX); decoder runs after backbone, not inside ViT blocks.
"""
import copy
import math
from typing import Optional

import numpy as np
import torch
import torch.nn as nn
import torch.nn.functional as F
from torch import Tensor


def get_sinusoid_encoding_table(n_position, d_hid, cls_token=False):
    def get_position_angle_vec(position):
        return [position / np.power(10000, 2 * (hid_j // 2) / d_hid) for hid_j in range(d_hid)]

    sinusoid_table = np.array([get_position_angle_vec(pos_i) for pos_i in range(n_position)])
    sinusoid_table[:, 0::2] = np.sin(sinusoid_table[:, 0::2])
    sinusoid_table[:, 1::2] = np.cos(sinusoid_table[:, 1::2])
    pos_embed = sinusoid_table
    if cls_token:
        pos_embed = np.concatenate([np.zeros([1, d_hid]), pos_embed], axis=0)
    return pos_embed


class MLP(nn.Module):
    def __init__(self, input_dim, hidden_dim, output_dim, num_layers):
        super().__init__()
        self.num_layers = num_layers
        h = [hidden_dim] * (num_layers - 1)
        self.layers = nn.ModuleList(nn.Linear(n, k) for n, k in zip([input_dim] + h, h + [output_dim]))

    def forward(self, x):
        for i, layer in enumerate(self.layers):
            x = F.relu(layer(x)) if i < self.num_layers - 1 else layer(x)
        return x


def generate_square_subsequent_mask(sz):
    mask = (torch.triu(torch.ones(sz, sz)) == 1).transpose(0, 1)
    return mask.float().masked_fill(mask == 0, float('-inf')).masked_fill(mask == 1, float(0.0))


class DecoderEmbeddings(nn.Module):
    def __init__(self, vocab_size, hidden_dim, max_position_embeddings, dropout):
        super().__init__()
        self.word_embeddings = nn.Embedding(vocab_size, hidden_dim)
        self.position_embeddings = nn.Embedding(max_position_embeddings, hidden_dim)
        self.LayerNorm = nn.LayerNorm(hidden_dim)
        self.dropout = nn.Dropout(dropout)

    def forward(self, x):
        input_embeds = self.word_embeddings(x)
        embeddings = self.LayerNorm(self.dropout(input_embeds))
        return embeddings


class TransformerDecoderLayer(nn.Module):
    def __init__(self, d_model, nhead, dim_feedforward=2048, dropout=0.1,
                 activation="relu", normalize_before=False):
        super().__init__()
        self.self_attn = nn.MultiheadAttention(d_model, nhead, dropout=dropout, batch_first=False)
        self.multihead_attn = nn.MultiheadAttention(d_model, nhead, dropout=dropout, batch_first=False)
        self.linear1 = nn.Linear(d_model, dim_feedforward)
        self.dropout = nn.Dropout(dropout)
        self.linear2 = nn.Linear(dim_feedforward, d_model)
        self.norm1 = nn.LayerNorm(d_model)
        self.norm2 = nn.LayerNorm(d_model)
        self.norm3 = nn.LayerNorm(d_model)
        self.dropout1 = nn.Dropout(dropout)
        self.dropout2 = nn.Dropout(dropout)
        self.dropout3 = nn.Dropout(dropout)
        self.activation = F.relu if activation == "relu" else F.gelu
        self.normalize_before = normalize_before

    def with_pos_embed(self, tensor, pos: Optional[Tensor]):
        return tensor if pos is None else tensor + pos

    def forward(self, tgt, memory, tgt_mask=None, memory_mask=None,
                tgt_key_padding_mask=None, memory_key_padding_mask=None,
                pos: Optional[Tensor] = None, query_pos: Optional[Tensor] = None):
        q = k = self.with_pos_embed(tgt, query_pos)
        tgt2 = self.self_attn(q, k, tgt, attn_mask=tgt_mask,
                              key_padding_mask=tgt_key_padding_mask)[0]
        tgt = tgt + self.dropout1(tgt2)
        tgt = self.norm1(tgt)
        tgt2 = self.multihead_attn(
            self.with_pos_embed(tgt, query_pos),
            self.with_pos_embed(memory, pos),
            memory, attn_mask=memory_mask,
            key_padding_mask=memory_key_padding_mask)[0]
        tgt = tgt + self.dropout2(tgt2)
        tgt = self.norm2(tgt)
        tgt2 = self.linear2(self.dropout(self.activation(self.linear1(tgt))))
        tgt = tgt + self.dropout3(tgt2)
        tgt = self.norm3(tgt)
        return tgt


def _get_clones(module, N):
    return nn.ModuleList([copy.deepcopy(module) for i in range(N)])


class TransformerDecoder(nn.Module):
    def __init__(self, decoder_layer, num_layers, norm=None, return_intermediate=False):
        super().__init__()
        self.layers = _get_clones(decoder_layer, num_layers)
        self.num_layers = num_layers
        self.norm = norm
        self.return_intermediate = return_intermediate

    def forward(self, tgt, memory, tgt_mask=None, memory_mask=None,
                tgt_key_padding_mask=None, memory_key_padding_mask=None,
                pos=None, query_pos=None):
        output = tgt
        for layer in self.layers:
            output = layer(output, memory, tgt_mask=tgt_mask, memory_mask=memory_mask,
                           tgt_key_padding_mask=tgt_key_padding_mask,
                           memory_key_padding_mask=memory_key_padding_mask,
                           pos=pos, query_pos=query_pos)
        if self.norm is not None:
            output = self.norm(output)
        return output.unsqueeze(0)


class SeqTrackDecoder(nn.Module):
    def __init__(self, d_model=192, nhead=4, num_decoder_layers=2, dim_feedforward=512,
                 dropout=0.1, activation="relu", normalize_before=False,
                 bins=1000, num_frames=1):
        super().__init__()
        self.bins = bins
        self.num_frames = num_frames
        self.num_coordinates = 4
        max_position_embeddings = (self.num_coordinates + 1) * num_frames
        self.embedding = DecoderEmbeddings(bins + 2, d_model, max_position_embeddings, dropout)
        decoder_layer = TransformerDecoderLayer(d_model, nhead, dim_feedforward, dropout, activation, normalize_before)
        decoder_norm = nn.LayerNorm(d_model)
        self.body = TransformerDecoder(decoder_layer, num_decoder_layers, decoder_norm, return_intermediate=False)
        self.d_model = d_model
        self.nhead = nhead

    def forward(self, src, pos_embed, seq):
        tgt = self.embedding(seq).permute(1, 0, 2)
        n, bs, c = src.shape
        query_embed = self.embedding.position_embeddings.weight.unsqueeze(1)
        query_embed = query_embed.repeat(1, bs, 1)
        memory = src
        tgt_mask = generate_square_subsequent_mask(len(tgt)).to(tgt.device)
        hs = self.body(tgt, memory, pos=pos_embed, query_pos=query_embed[:len(tgt)],
                       tgt_mask=tgt_mask, memory_mask=None)
        return hs.transpose(1, 2)


class SGLATrackSeqHead(nn.Module):
    """
    Memory: search-region tokens only (B, N, C). C == d_model.
    Training: teacher-forcing with seq input [START, x,y,w,h] -> predict [x,y,w,h, END] via CE.
    """
    def __init__(self, embed_dim, num_search_patches, bins=1000,
                 nhead=4, dec_layers=2, dim_ff=512, dropout=0.1):
        super().__init__()
        self.num_coordinates = 4
        self.embed_dim = embed_dim
        self.num_search_patches = num_search_patches
        self.bins = bins
        self.start_token = bins + 1
        self.end_token = bins
        self.vocab_size = bins + 2

        self.decoder = SeqTrackDecoder(
            d_model=embed_dim, nhead=nhead, num_decoder_layers=dec_layers,
            dim_feedforward=dim_ff, dropout=dropout, activation='relu',
            normalize_before=False, bins=bins, num_frames=1)
        self.vocab_embed = MLP(embed_dim, embed_dim, self.vocab_size, 3)

        pe = get_sinusoid_encoding_table(num_search_patches, embed_dim, cls_token=False)
        self.mem_pos = nn.Parameter(torch.zeros(1, num_search_patches, embed_dim))
        self.mem_pos.data.copy_(torch.from_numpy(pe).float().unsqueeze(0))

    def forward(self, search_tokens, seq_input):
        """
        search_tokens: (B, N, C)
        seq_input: (B, L) long, teacher input [START]+4 coords
        Returns logits (B, L, vocab_size)
        """
        B, N, C = search_tokens.shape
        dec_mem = search_tokens.permute(1, 0, 2)
        pos = self.mem_pos.permute(1, 0, 2).expand(-1, B, -1)
        dec_out = self.decoder(dec_mem, pos, seq_input)
        dec_out = dec_out[-1]
        logits = self.vocab_embed(dec_out)
        return logits

    @torch.no_grad()
    def inference(self, search_tokens, seq_format='xywh'):
        B, N, C = search_tokens.shape
        device = search_tokens.device
        dec_mem = search_tokens.permute(1, 0, 2)
        pos = self.mem_pos.permute(1, 0, 2).expand(-1, B, -1)
        seq = torch.full((B, 1), self.start_token, dtype=torch.long, device=device)
        box_pos = [0, 1, 2, 3]
        for i in range(self.num_coordinates):
            tgt = self.decoder.embedding(seq).permute(1, 0, 2)
            query_embed = self.decoder.embedding.position_embeddings.weight.unsqueeze(1).repeat(1, B, 1)
            tgt_mask = generate_square_subsequent_mask(len(tgt)).to(device)
            hs = self.decoder.body(
                tgt, dec_mem, pos=pos, query_pos=query_embed[:len(tgt)],
                tgt_mask=tgt_mask, memory_mask=None)
            hs = hs.squeeze(0)
            out = self.vocab_embed(hs[-1:])
            out = out.squeeze(0)
            out = out.softmax(-1)
            if i in box_pos:
                out = out[:, :self.bins]
            _, token_generated = out.topk(dim=-1, k=1)
            seq = torch.cat([seq, token_generated], dim=-1)
        tokens = seq[:, 1:5].float() / max(self.bins - 1, 1)
        if seq_format == 'whxy':
            tokens = tokens[:, [2, 3, 0, 1]]
        return tokens
