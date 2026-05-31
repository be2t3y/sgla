#!/bin/bash
# 在 s3lab_research_v2 根目錄執行；使用 conda env sgla 跑 vit_coco_got10k_mala_relu6 全流程。
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"
if [[ -f "/home/junjie/anaconda3/etc/profile.d/conda.sh" ]]; then
  # shellcheck source=/dev/null
  source "/home/junjie/anaconda3/etc/profile.d/conda.sh"
  conda activate sgla
fi
export CONFIG="${CONFIG:-vit_coco_got10k_mala_relu6}"
export NUM_GPUS="${NUM_GPUS:-1}"
export TEST_NUM_GPUS="${TEST_NUM_GPUS:-1}"
export DATASET="${DATASET:-uav123}"
export MODE="${MODE:-multiple}"
exec bash python/run_all.sh
