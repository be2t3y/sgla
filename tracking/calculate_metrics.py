"""
計算追蹤結果的 AUC 和 Precision
Usage:
  python tracking/calculate_metrics.py --tracker sglatrack --param deit_distilled --dataset uav123
  # 與 test.py --sequence_list_file 子集一致時，請帶同一個清單，否則會缺結果檔而報錯
  python tracking/calculate_metrics.py --tracker sglatrack --param deit_distilled_coco_got10k_uav6_half \\
      --dataset uavtrack112 --sequence_list_file output/uav6_split_seed42/UAVTrack112.V50.for_test.txt
"""
import _init_paths
import argparse
import os
import matplotlib
matplotlib.use('Agg')  # 無 display 環境下使用
import matplotlib.pyplot as plt
from lib.test.analysis.plot_results import print_results, check_and_load_precomputed_results
from lib.test.evaluation import get_dataset, trackerlist
from lib.test.evaluation.data import SequenceList
from lib.test.evaluation.environment import env_settings
import torch


def _read_sequence_list_file(path):
    names = []
    with open(path, "r") as f:
        for line in f:
            line = line.strip()
            if not line or line.startswith("#"):
                continue
            names.append(line)
    return names


def parse_args():
    parser = argparse.ArgumentParser(description='計算 AUC 和 Precision 指標')
    parser.add_argument('--tracker', type=str, default='sglatrack', help='Tracker 名稱')
    parser.add_argument('--param', type=str, default='deit_distilled', help='參數檔名稱')
    parser.add_argument('--dataset', type=str, default='uav123', help='資料集名稱 (uav123, uav123_10fps, lasot, etc.)')
    parser.add_argument(
        '--sequence_list_file', type=str, default=None,
        help='與 tracking/test.py 相同：每行一個 sequence 名稱，只對這些序列彙總（須已有對應 .txt 結果）',
    )
    parser.add_argument('--runid', type=int, default=None, help='Run ID (可選)')
    parser.add_argument('--display_name', type=str, default=None, help='顯示名稱 (可選)')
    parser.add_argument('--merge', action='store_true', help='合併多次執行的結果')
    parser.add_argument('--plot', action='store_true', help='生成簡化版圖表（不需要 LaTeX）')
    
    args = parser.parse_args()
    return args


def plot_simple_curves(eval_data, dataset_name, result_path):
    """生成簡化版本的圖表（不需要 LaTeX）- 分別輸出兩張圖"""
    
    # 停用 LaTeX
    plt.rcParams['text.usetex'] = False
    
    valid_sequence = torch.tensor(eval_data['valid_sequence'], dtype=torch.bool)
    tracker_names = eval_data['trackers']
    
    # Success plot (AUC)
    ave_success_rate_plot_overlap = torch.tensor(eval_data['ave_success_rate_plot_overlap'])
    ave_success_rate_plot_overlap = ave_success_rate_plot_overlap[valid_sequence, :, :]
    auc_curve = ave_success_rate_plot_overlap.mean(0) * 100.0
    auc = auc_curve.mean(-1)
    threshold_set_overlap = torch.tensor(eval_data['threshold_set_overlap'])
    
    # Precision plot
    ave_success_rate_plot_center = torch.tensor(eval_data['ave_success_rate_plot_center'])
    ave_success_rate_plot_center = ave_success_rate_plot_center[valid_sequence, :, :]
    prec_curve = ave_success_rate_plot_center.mean(0) * 100.0
    prec_score = prec_curve[:, 20]
    threshold_set_center = torch.tensor(eval_data['threshold_set_center'])
    
    # 確保輸出目錄存在
    os.makedirs(result_path, exist_ok=True)
    
    # ==================== 圖表 1: Success Plot ====================
    fig1, ax1 = plt.subplots(figsize=(10, 8))
    
    for i in range(auc_curve.shape[0]):
        tracker = tracker_names[i]
        disp_name = tracker['disp_name'] if tracker['disp_name'] else f"{tracker['name']}_{tracker['param']}"
        ax1.plot(threshold_set_overlap.tolist(), auc_curve[i, :].tolist(), 
                linewidth=2, label=f'{disp_name} [{auc[i]:.1f}]')
    
    ax1.set_xlabel('Overlap threshold', fontsize=16)
    ax1.set_ylabel('Overlap Precision [%]', fontsize=16)
    ax1.set_title(f'Success Plot - {dataset_name}', fontsize=18, fontweight='bold')
    ax1.set_xlim(0, 1.0)
    ax1.set_ylim(0, 100)
    ax1.grid(True, linestyle='--', alpha=0.7)
    ax1.legend(loc='lower left', fontsize=14)
    ax1.tick_params(labelsize=14)
    
    plt.tight_layout()
    
    # 保存 Success Plot
    success_file = os.path.join(result_path, f'{dataset_name}_success_plot.pdf')
    plt.savefig(success_file, dpi=300, bbox_inches='tight', format='pdf')
    print(f"✓ Success Plot 已保存至: {success_file}")
    
    plt.close(fig1)
    
    # ==================== 圖表 2: Precision Plot ====================
    fig2, ax2 = plt.subplots(figsize=(10, 8))
    
    for i in range(prec_curve.shape[0]):
        tracker = tracker_names[i]
        disp_name = tracker['disp_name'] if tracker['disp_name'] else f"{tracker['name']}_{tracker['param']}"
        ax2.plot(threshold_set_center.tolist(), prec_curve[i, :].tolist(), 
                linewidth=2, label=f'{disp_name} [{prec_score[i]:.1f}]')
    
    ax2.set_xlabel('Location error threshold [pixels]', fontsize=16)
    ax2.set_ylabel('Distance Precision [%]', fontsize=16)
    ax2.set_title(f'Precision Plot - {dataset_name}', fontsize=18, fontweight='bold')
    ax2.set_xlim(0, 50)
    ax2.set_ylim(0, 100)
    ax2.grid(True, linestyle='--', alpha=0.7)
    ax2.legend(loc='lower right', fontsize=14)
    ax2.tick_params(labelsize=14)
    
    plt.tight_layout()
    
    # 保存 Precision Plot
    precision_file = os.path.join(result_path, f'{dataset_name}_precision_plot.pdf')
    plt.savefig(precision_file, dpi=300, bbox_inches='tight', format='pdf')
    print(f"✓ Precision Plot 已保存至: {precision_file}")
    
    plt.close(fig2)
    
    print(f"\n✓ 所有圖表已保存至目錄: {result_path}")


def main():
    args = parse_args()
    
    print(f"\n{'='*70}")
    print(f"計算指標：{args.tracker} ({args.param}) on {args.dataset}")
    print(f"{'='*70}")
    
    # 建立 tracker 列表
    trackers = []
    display_name = args.display_name if args.display_name else f"{args.tracker}_{args.param}"
    
    trackers.extend(trackerlist(
        name=args.tracker,
        parameter_name=args.param,
        dataset_name=args.dataset,
        run_ids=args.runid,
        display_name=display_name
    ))
    
    # 載入資料集（可選：與 test 相同的子集清單）
    dataset = get_dataset(args.dataset)
    if args.sequence_list_file is not None:
        wanted = set(_read_sequence_list_file(args.sequence_list_file))
        if not wanted:
            raise ValueError("Sequence list file is empty: %s" % args.sequence_list_file)
        dataset = SequenceList([s for s in dataset if s.name in wanted])
        missing = wanted - set(s.name for s in dataset)
        if missing:
            print("[calculate_metrics] Warning: %d names in list not found in dataset %s (showing up to 10): %s"
                  % (len(missing), args.dataset, list(sorted(missing))[:10]))
        if len(dataset) == 0:
            raise ValueError("No sequences left after filtering; check names match evaluation dataset.")

    # 計算並列印結果
    print_results(
        trackers,
        dataset,
        args.dataset,
        merge_results=args.merge,
        plot_types=('success', 'prec', 'norm_prec')
    )
    
    # 如果需要畫圖
    if args.plot:
        print(f"\n{'='*70}")
        print("生成圖表...")
        print(f"{'='*70}")
        
        settings = env_settings()
        result_plot_path = os.path.join(settings.result_plot_path, args.dataset)
        
        # 載入預計算結果
        eval_data = check_and_load_precomputed_results(trackers, dataset, args.dataset)
        
        # 生成簡化圖表
        plot_simple_curves(eval_data, args.dataset, result_plot_path)
    
    print(f"\n{'='*70}")
    print("計算完成！")
    print(f"{'='*70}\n")


if __name__ == '__main__':
    main()
