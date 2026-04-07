#!/usr/bin/env python3
"""匯出五個 UAV/DTB 資料集 T50/V50（不含 UAVDT，與 deit_distilled_coco_got10k_uav5_half 一致）。"""
from __future__ import print_function

import argparse
import os
import sys

_PRJ = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
if _PRJ not in sys.path:
    sys.path.insert(0, _PRJ)

from lib.train.admin.environment import env_settings
from lib.train.base_functions import (
    _collect_uav_sequence_names,
    _uav50_split_sequence_names,
)
from lib.train.data.image_loader import opencv_loader

# 與 uav5_half yaml 的 TRAIN 資料集一致（無 UAVDT）
_UAV5_BASES = (
    "UAV123",
    "UAV123_10FPS",
    "UAVTrack",
    "UAVTrack112",
    "DTB70",
)


def _internal_to_eval_sequence_name(base, internal_name):
    if base == "UAV123":
        if internal_name.startswith("uav_"):
            return internal_name
        return "uav_" + internal_name
    return internal_name


def _write_lines(path, lines):
    with open(path, "w") as f:
        for x in lines:
            f.write("%s\n" % x)


def main():
    ap = argparse.ArgumentParser(description="Dump UAV5 half splits (T50/V50), no UAVDT.")
    ap.add_argument("--out_dir", type=str, required=True)
    ap.add_argument("--seed", type=int, default=None)
    ap.add_argument(
        "--config",
        type=str,
        default=None,
        help="yaml with DATA.MIXED_UAV_SPLIT_SEED (e.g. experiments/sglatrack/deit_distilled_coco_got10k_uav5_half.yaml)",
    )
    args = ap.parse_args()

    seed = args.seed
    if args.config is not None:
        import yaml
        from easydict import EasyDict as edict

        cfg_path = args.config
        if not os.path.isfile(cfg_path) and not cfg_path.endswith(".yaml"):
            alt = cfg_path + ".yaml"
            if os.path.isfile(alt):
                cfg_path = alt
        with open(cfg_path) as f:
            exp = edict(yaml.safe_load(f))
        if seed is None and "DATA" in exp and "MIXED_UAV_SPLIT_SEED" in exp.DATA:
            seed = int(exp.DATA.MIXED_UAV_SPLIT_SEED)
    if seed is None:
        seed = 42

    out_dir = os.path.abspath(args.out_dir)
    os.makedirs(out_dir, exist_ok=True)

    class _S:
        pass

    settings = _S()
    settings.use_lmdb = False
    settings.env = env_settings()

    readme = os.path.join(out_dir, "README.txt")
    with open(readme, "w") as f:
        f.write("MIXED_UAV_SPLIT_SEED=%d (UAV5: no UAVDT)\n\n" % seed)
        f.write("Example:\n  python tracking/test.py sglatrack <param> --dataset_name uav123 "
                "--sequence_list_file %s/UAV123.V50.for_test.txt\n" % out_dir)

    for base in _UAV5_BASES:
        names = _collect_uav_sequence_names(base, settings, opencv_loader)
        t50, v50 = _uav50_split_sequence_names(names, seed, base)
        _write_lines(os.path.join(out_dir, "%s.T50.internal.txt" % base), t50)
        _write_lines(os.path.join(out_dir, "%s.V50.internal.txt" % base), v50)
        _write_lines(
            os.path.join(out_dir, "%s.V50.for_test.txt" % base),
            [_internal_to_eval_sequence_name(base, n) for n in v50],
        )
        print("%s: total=%d T50=%d V50=%d" % (base, len(names), len(t50), len(v50)))

    print("Done. Seed=%d. See %s" % (seed, readme))


if __name__ == "__main__":
    main()
