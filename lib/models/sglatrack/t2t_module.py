"""
T2T (Tokens-to-Token) module for SGLATrack.
Replaces patch_embed with soft-split + restructuring for richer tokenization.
Supports variable input size (template 128, search 256) for tracking.
"""
import numpy as np
import torch
import torch.nn as nn

from .token_performer import Token_performer


class T2T_module(nn.Module):
    """
    Tokens-to-Token encoding module.
    Supports variable img_size (e.g. 128 for template, 256 for search).
    Output: (B, num_patches, embed_dim) with num_patches = (img_size/16)^2
    """

    def __init__(self, img_size=224, tokens_type='performer', in_chans=3, embed_dim=192, token_dim=64):
        super().__init__()
        self.embed_dim = embed_dim
        self.img_size = img_size
        self.num_patches = (img_size // 16) * (img_size // 16)

        if tokens_type == 'performer':
            self.soft_split0 = nn.Unfold(kernel_size=(7, 7), stride=(4, 4), padding=(2, 2))
            self.soft_split1 = nn.Unfold(kernel_size=(3, 3), stride=(2, 2), padding=(1, 1))
            self.soft_split2 = nn.Unfold(kernel_size=(3, 3), stride=(2, 2), padding=(1, 1))
            self.attention1 = Token_performer(dim=in_chans * 7 * 7, in_dim=token_dim, kernel_ratio=0.5)
            self.attention2 = Token_performer(dim=token_dim * 3 * 3, in_dim=token_dim, kernel_ratio=0.5)
            self.project = nn.Linear(token_dim * 3 * 3, embed_dim)
        else:
            raise NotImplementedError(f' tokens_type={tokens_type}')

    def forward(self, x):
        # x: (B, 3, H, W)
        x = self.soft_split0(x).transpose(1, 2)

        x = self.attention1(x)
        B, new_HW, C = x.shape
        new_H = int(np.sqrt(new_HW))
        x = x.transpose(1, 2).reshape(B, C, new_H, new_H)

        x = self.soft_split1(x).transpose(1, 2)
        x = self.attention2(x)
        B, new_HW, C = x.shape
        new_H = int(np.sqrt(new_HW))
        x = x.transpose(1, 2).reshape(B, C, new_H, new_H)

        x = self.soft_split2(x).transpose(1, 2)
        x = self.project(x)
        return x
