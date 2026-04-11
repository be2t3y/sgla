# Learned PE for AQATrack-style query decoder (sz×sz grid, typically sz=1).
import torch
from torch import nn


class PositionEmbeddingLearnedQuery(nn.Module):

    def __init__(self, num_pos_feats, sz=1):
        super().__init__()
        self.sz = int(sz)
        self.row_embed = nn.Embedding(self.sz, num_pos_feats)
        self.col_embed = nn.Embedding(self.sz, num_pos_feats)
        nn.init.uniform_(self.row_embed.weight)
        nn.init.uniform_(self.col_embed.weight)

    def forward(self, bs):
        h, w = self.sz, self.sz
        i = torch.arange(w, device=self.col_embed.weight.device)
        j = torch.arange(h, device=self.row_embed.weight.device)
        x_emb = self.col_embed(i)
        y_emb = self.row_embed(j)
        pos = torch.cat([
            x_emb.unsqueeze(0).repeat(h, 1, 1),
            y_emb.unsqueeze(1).repeat(1, w, 1),
        ], dim=-1).repeat(1, int(bs), 1)
        return pos


def build_aqa_position_encoding(hidden_dim, sz=1):
    n_steps = hidden_dim // 2
    return PositionEmbeddingLearnedQuery(n_steps, sz=sz)
