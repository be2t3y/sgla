class EnvironmentSettings:
    def __init__(self):
        # 控制 train / val / test 使用的 GPU（改這裡即可，三處共用）
        # 例：只用一張 "0"；多張 "0,1" 或 "0,1,2,3"
        self.cuda_visible_devices = "0"

        self.workspace_dir = '/home/junjie/01_Research/SGLATrack-main'    # Base directory for saving network checkpoints.
        self.tensorboard_dir = '/home/junjie/01_Research/SGLATrack-main/tensorboard'    # Directory for tensorboard files.
        self.pretrained_networks = '/home/junjie/01_Research/SGLATrack-main/pretrained_networks'
        self.lasot_dir = '/home/junjie/01_Research/SGLATrack-main/data/lasot'
        # GOT-10k 實際目錄為 data/got-10k/GOT-10k/train（內含 list.txt）
        self.got10k_dir = '/home/junjie/01_Research/SGLATrack-main/data/got-10k/GOT-10k/train'
        self.got10k_val_dir = '/home/junjie/01_Research/SGLATrack-main/data/got-10k/GOT-10k/val'
        self.lasot_lmdb_dir = '/home/junjie/01_Research/SGLATrack-main/data/lasot_lmdb'
        self.got10k_lmdb_dir = '/home/junjie/01_Research/SGLATrack-main/data/got10k_lmdb'
        self.trackingnet_dir = '/home/junjie/01_Research/SGLATrack-main/data/trackingnet'
        self.trackingnet_lmdb_dir = '/home/junjie/01_Research/SGLATrack-main/data/trackingnet_lmdb'
        self.coco_dir = '/home/junjie/01_Research/SGLATrack-main/data/coco'
        self.coco_lmdb_dir = '/home/junjie/01_Research/SGLATrack-main/data/coco_lmdb'
        self.lvis_dir = ''
        self.sbd_dir = ''
        self.imagenet_dir = '/home/junjie/01_Research/SGLATrack-main/data/vid'
        self.imagenet_lmdb_dir = '/home/junjie/01_Research/SGLATrack-main/data/vid_lmdb'
        self.imagenetdet_dir = ''
        self.ecssd_dir = ''
        self.hkuis_dir = ''
        self.msra10k_dir = ''
        self.davis_dir = ''
        self.youtubevos_dir = ''
        self.uav123_dir = '/home/junjie/01_Research/SGLATrack-main/data/uav123/UAV123'
        # 下面這些原本多用於 test benchmark；若要拿來 train，請確保資料夾結構與標註存在
        self.uav123_10fps_dir = '/home/junjie/01_Research/SGLATrack-main/data/uav123_10fps/UAV123_10fps'
        # UAVTrack / UAVTrack112 共用同一資料根目錄（依 repo 的 test 設定）
        self.uavtrack_dir = '/home/junjie/01_Research/SGLATrack-main/data/uavtrack112/home/data/V4RFlight112'
        self.uavdt_dir = '/home/junjie/01_Research/SGLATrack-main/data/uavdt/home/data/uavdt'
        self.dtb70_dir = '/home/junjie/01_Research/SGLATrack-main/data/dtb70/DTB70'
        self.visdrone_dir = '/home/junjie/01_Research/SGLATrack-main/data/visdrone/VisDrone2018-SOT-test-dev'
