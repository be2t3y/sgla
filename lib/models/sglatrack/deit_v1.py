# Copyright (c) 2015-present, Facebook, Inc.
# All rights reserved.
import torch
import torch.nn as nn
from functools import partial

from timm.models.vision_transformer import VisionTransformer, _cfg
from timm.models.registry import register_model
from timm.models.layers import trunc_normal_
from lib.models.sglatrack.base_backbone import BaseBackbone
from lib.models.sglatrack.t2t_module import T2T_module

__all__ = [
    'deit_tiny_patch16_224', 'deit_small_patch16_224', 'deit_base_patch16_224',
    'deit_tiny_distilled_patch16_224', 'deit_small_distilled_patch16_224',
    'deit_base_distilled_patch16_224', 'deit_base_patch16_384',
    'deit_base_distilled_patch16_384',
    'deit_tiny_t2t_distilled_patch16_224',
]


class DistilledVisionTransformer(VisionTransformer,BaseBackbone):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        # self.dist_token = nn.Parameter(torch.zeros(1, 1, self.embed_dim))
        num_patches = self.patch_embed.num_patches
        self.pos_embed = nn.Parameter(torch.zeros(1, num_patches + 2, self.embed_dim))
        # self.head_dist = nn.Linear(self.embed_dim, self.num_classes) if self.num_classes > 0 else nn.Identity()

        # trunc_normal_(self.dist_token, std=.02)
        trunc_normal_(self.pos_embed, std=.02)
        # self.head_dist.apply(self._init_weights)

##
    def forward(self, z, x, **kwargs):

        x = BaseBackbone.forward(self, z, x, **kwargs)

        return x



def deit_tiny_patch16_224(pretrained=False, **kwargs):
    model = VisionTransformer(
        patch_size=16, embed_dim=192, depth=12, num_heads=3, mlp_ratio=4, qkv_bias=True,
        norm_layer=partial(nn.LayerNorm, eps=1e-6), **kwargs)
    model.default_cfg = _cfg()
    if pretrained:
        checkpoint = torch.hub.load_state_dict_from_url(
            url="https://dl.fbaipublicfiles.com/deit/deit_tiny_patch16_224-a1311bcf.pth",
            map_location="cpu", check_hash=True
        )
        model.load_state_dict(checkpoint["model"])
    return model


def deit_tiny_distilled_patch16_224(pretrained=False, **kwargs):

    model = DistilledVisionTransformer(
        patch_size=16, embed_dim=192, depth=12, num_heads=3, mlp_ratio=4, qkv_bias=True,
        norm_layer=partial(nn.LayerNorm, eps=1e-6), **kwargs)
    model.default_cfg = _cfg()

    if pretrained:
            checkpoint = torch.load(pretrained, map_location="cpu")
            missing_keys, unexpected_keys = model.load_state_dict(checkpoint['model'], strict=False)
            print(missing_keys, unexpected_keys)
            print('Load pretrained model from: ' + pretrained)

    return model


def deit_tiny_t2t_distilled_patch16_224(pretrained=False, **kwargs):
    """
    DeiT-Tiny with T2T (Tokens-to-Token) replacing patch_embed.
    """
    model = DistilledVisionTransformer(
        patch_size=16, embed_dim=192, depth=12, num_heads=3, mlp_ratio=4, qkv_bias=True,
        norm_layer=partial(nn.LayerNorm, eps=1e-6), **kwargs)
    model.default_cfg = _cfg()

    model.patch_embed = T2T_module(
        img_size=224, tokens_type='performer', in_chans=3, embed_dim=192, token_dim=64
    )
    model.pos_embed = nn.Parameter(torch.zeros(1, 196 + 2, 192))
    trunc_normal_(model.pos_embed, std=.02)

    if pretrained:
        checkpoint = torch.load(pretrained, map_location="cpu")
        ckpt = checkpoint.get('model', checkpoint.get('net', checkpoint))
        model_keys = set(model.state_dict().keys())
        partial_state = {k: ckpt[k] for k in ckpt if not k.startswith('patch_embed') and k in model_keys}
        model.load_state_dict(partial_state, strict=False)
        print('Loaded pretrained (excluding patch_embed) from:', pretrained)

    return model
