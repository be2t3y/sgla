#!/usr/bin/env python3
"""
從官方 T2T-ViT-14 ImageNet checkpoint 載入 tokens_to_token 權重到 SGLATrack backbone.patch_embed。

用法:
  wget https://github.com/yitu-opensource/T2T-ViT/releases/download/main/81.5_T2T_ViT_14.pth.tar -O output/checkpoints/t2t_vit14_imagenet.pth.tar
  python scripts/load_t2t_pretrain.py --ckpt output/checkpoints/t2t_vit14_imagenet.pth.tar --inspect
  python scripts/load_t2t_pretrain.py --ckpt output/checkpoints/t2t_vit14_imagenet.pth.tar \\
    --base_pretrain output/checkpoints/train/sglatrack/deit_distilled/sglatrack_ep0297.pth.tar
"""
import argparse
import os
import sys

import torch

PROJECT_ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, PROJECT_ROOT)
os.chdir(PROJECT_ROOT)


def load_checkpoint(ckpt_path):
    ckpt = torch.load(ckpt_path, map_location="cpu")
    if isinstance(ckpt, dict):
        if "state_dict_ema" in ckpt:
            sd = ckpt["state_dict_ema"]
        elif "state_dict" in ckpt:
            sd = ckpt["state_dict"]
        else:
            sd = ckpt
    else:
        sd = ckpt
    new_sd = {}
    for k, v in sd.items():
        name = k[7:] if k.startswith("module.") else k
        new_sd[name] = v
    return new_sd


def inspect_keys(sd, prefix="tokens_to_token"):
    print(f"\n=== Keys 含 '{prefix}' ===\n")
    for k in sorted(sd.keys()):
        if prefix in k:
            print(f"  {k}: {sd[k].shape}")
    print()


def build_t2t_mapping(ckpt_sd, target_prefix="backbone.patch_embed", source_prefix="tokens_to_token"):
    mapping = {}
    for k, v in ckpt_sd.items():
        if not k.startswith(source_prefix + "."):
            continue
        rest = k[len(source_prefix) + 1 :]
        new_k = f"{target_prefix}.{rest}"
        if "project" in k:
            if "weight" in k:
                mapping[new_k] = v[:192].clone()
            elif "bias" in k:
                mapping[new_k] = v[:192].clone()
            else:
                mapping[new_k] = v.clone()
        else:
            mapping[new_k] = v.clone()
    return mapping


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--ckpt", type=str, required=True)
    parser.add_argument("--inspect", action="store_true")
    parser.add_argument("--output", type=str, default=None)
    parser.add_argument("--base_pretrain", type=str, default=None)
    args = parser.parse_args()

    if not os.path.isfile(args.ckpt):
        print(f"Error: 找不到 {args.ckpt}")
        return 1

    ckpt_sd = load_checkpoint(args.ckpt)
    inspect_keys(ckpt_sd)
    if args.inspect:
        return 0

    mapping = build_t2t_mapping(ckpt_sd)
    print("=== 對應後 keys (backbone.patch_embed.*) ===\n")
    for k in sorted(mapping.keys()):
        print(f"  {k}: {mapping[k].shape}")
    print()

    import importlib
    config_module = importlib.import_module("lib.config.sglatrack.config")
    cfg = config_module.cfg
    yaml_path = os.path.join(PROJECT_ROOT, "experiments", "sglatrack", "deit_t2t_distilled_coco_got10k.yaml")
    if os.path.isfile(yaml_path):
        config_module.update_config_from_file(yaml_path)
    else:
        cfg.MODEL.BACKBONE.TYPE = "deit_tiny_t2t_distilled_patch16"

    old_pretrain = cfg.MODEL.PRETRAIN_FILE
    cfg.MODEL.PRETRAIN_FILE = ""

    from lib.models.sglatrack import build_sglatrack
    model = build_sglatrack(cfg)
    cfg.MODEL.PRETRAIN_FILE = old_pretrain

    out_sd = model.state_dict()
    model_keys = set(out_sd.keys())
    loaded = 0
    for k, v in mapping.items():
        if k in model_keys:
            out_sd[k].copy_(v)
            loaded += 1
        else:
            print(f"  [skip] {k}")

    print(f"\n已載入 {loaded} 個 T2T 參數到 backbone.patch_embed")

    if args.base_pretrain and os.path.isfile(args.base_pretrain):
        base = torch.load(args.base_pretrain, map_location="cpu")
        base_sd = base.get("net", base.get("model", base))
        merged = 0
        for k, v in base_sd.items():
            name = k[7:] if k.startswith("module.") else k
            if name in out_sd and "patch_embed" not in name:
                if out_sd[name].shape == v.shape:
                    out_sd[name].copy_(v)
                    merged += 1
        print(f"已合併 {merged} 個參數從 {args.base_pretrain}")

    out_path = args.output or os.path.join(PROJECT_ROOT, "output", "checkpoints", "sglatrack_deit_t2t_with_t2t_pretrain.pth.tar")
    os.makedirs(os.path.dirname(out_path), exist_ok=True)
    torch.save({"net": out_sd, "epoch": 0}, out_path)
    print(f"\n已儲存: {out_path}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
