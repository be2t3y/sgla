import os
import sys
import argparse

prj_path = os.path.join(os.path.dirname(__file__), '..')
if prj_path not in sys.path:
    sys.path.append(prj_path)

# GPU 使用哪幾張由 lib/train/admin/local.py 的 cuda_visible_devices 控制（與 train/val 共用）
try:
    from lib.train.admin.local import EnvironmentSettings
    _env = EnvironmentSettings()
    os.environ["CUDA_VISIBLE_DEVICES"] = getattr(_env, "cuda_visible_devices", "0")
except Exception:
    os.environ.setdefault("CUDA_VISIBLE_DEVICES", "0")

from lib.test.evaluation import get_dataset
from lib.test.evaluation.data import SequenceList
from lib.test.evaluation.running import run_dataset
from lib.test.evaluation.tracker import Tracker


def _read_sequence_list_file(path):
    names = []
    with open(path, "r") as f:
        for line in f:
            line = line.strip()
            if not line or line.startswith("#"):
                continue
            names.append(line)
    return names


def run_tracker(tracker_name, tracker_param, run_id=None, dataset_name='otb', sequence=None,
                sequence_list_file=None, debug=0, threads=0, num_gpus=8):
    """Run tracker on sequence or dataset.
    args:
        tracker_name: Name of tracking method.
        tracker_param: Name of parameter file.
        run_id: The run id.
        dataset_name: Name of dataset (otb, nfs, uav, tpl, vot, tn, gott, gotv, lasot).
        sequence: Sequence number or name.
        sequence_list_file: Text file with one sequence name per line.
        debug: Debug level.
        threads: Number of threads.
    """

    dataset = get_dataset(dataset_name)

    if sequence_list_file is not None:
        if sequence is not None:
            raise ValueError("Use either --sequence or --sequence_list_file, not both.")
        wanted = set(_read_sequence_list_file(sequence_list_file))
        if not wanted:
            raise ValueError("Sequence list file is empty: %s" % sequence_list_file)
        filtered = SequenceList([s for s in dataset if s.name in wanted])
        missing = wanted - set(s.name for s in filtered)
        if missing:
            print("[test] Warning: %d names in list not found in dataset %s (showing up to 10): %s"
                  % (len(missing), dataset_name, list(sorted(missing))[:10]))
        if len(filtered) == 0:
            raise ValueError(
                "No sequences left after filtering; check names match evaluation dataset (e.g. uav123 uses uav_*)."
            )
        dataset = filtered
    elif sequence is not None:
        dataset = [dataset[sequence]]

    trackers = [Tracker(tracker_name, tracker_param, dataset_name, run_id)]

    run_dataset(dataset, trackers, debug, threads, num_gpus=num_gpus)


def main():
    parser = argparse.ArgumentParser(description='Run tracker on sequence or dataset.')
    parser.add_argument('tracker_name', type=str, help='Name of tracking method.')
    parser.add_argument('tracker_param', type=str, help='Name of config file.')
    parser.add_argument('--runid', type=int, default=None, help='The run id.')
    parser.add_argument('--dataset_name', type=str, default='uavdt', help='Name of dataset (otb, nfs, uav, tpl, vot, tn, gott, gotv, lasot).')
    parser.add_argument('--sequence', type=str, default=None, help='Sequence number or name.')
    parser.add_argument('--sequence_list_file', type=str, default=None,
                        help='Text file: one sequence name per line (# comments ok). Subset of --dataset_name.')
    parser.add_argument('--debug', type=int, default=0, help='Debug level.')
    parser.add_argument('--threads', type=int, default=0, help='Number of threads.')
    parser.add_argument('--num_gpus', type=int, default=1)

    args = parser.parse_args()

    try:
        seq_name = int(args.sequence)
    except:
        seq_name = args.sequence

    run_tracker(
        args.tracker_name,
        args.tracker_param,
        args.runid,
        args.dataset_name,
        seq_name,
        sequence_list_file=args.sequence_list_file,
        debug=args.debug,
        threads=args.threads,
        num_gpus=args.num_gpus,
    )


if __name__ == '__main__':
    main()
