import os


def _python_root():
    """Directory that contains tracking/, lib/, experiments/ (the `python/` folder)."""
    root = os.environ.get('SGLATRACK_PYTHON_ROOT', '').strip()
    if root:
        return os.path.abspath(root)
    # this file: python/lib/train/admin/local.py
    return os.path.abspath(os.path.join(os.path.dirname(__file__), '..', '..', '..'))


def _data_dir():
    """Dataset root; default `<python>/data`. Override with env SGLATRACK_DATA_DIR."""
    d = os.environ.get('SGLATRACK_DATA_DIR', '').strip()
    if d:
        return os.path.abspath(d)
    return os.path.join(_python_root(), 'data')


class EnvironmentSettings:
    def __init__(self):
        prj = _python_root()
        data = _data_dir()
        self.workspace_dir = prj    # Base directory for saving network checkpoints.
        self.tensorboard_dir = os.path.join(prj, 'tensorboard')    # Directory for tensorboard files.
        self.pretrained_networks = os.path.join(prj, 'pretrained_networks')
        self.lasot_dir = os.path.join(data, 'lasot')
        self.got10k_dir = os.path.join(data, 'got10k', 'train')
        self.got10k_val_dir = os.path.join(data, 'got10k', 'val')
        self.lasot_lmdb_dir = os.path.join(data, 'lasot_lmdb')
        self.got10k_lmdb_dir = os.path.join(data, 'got10k_lmdb')
        self.trackingnet_dir = os.path.join(data, 'trackingnet')
        self.trackingnet_lmdb_dir = os.path.join(data, 'trackingnet_lmdb')
        self.coco_dir = os.path.join(data, 'coco')
        self.coco_lmdb_dir = os.path.join(data, 'coco_lmdb')
        self.lvis_dir = ''
        self.sbd_dir = ''
        self.imagenet_dir = os.path.join(data, 'vid')
        self.imagenet_lmdb_dir = os.path.join(data, 'vid_lmdb')
        self.imagenetdet_dir = ''
        self.ecssd_dir = ''
        self.hkuis_dir = ''
        self.msra10k_dir = ''
        self.davis_dir = ''
        self.youtubevos_dir = ''
        self.uav123_dir = os.path.join(data, 'uav123', 'UAV123')
