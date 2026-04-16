class EnvironmentSettings:
    def __init__(self):
        # s3lab 程式從 s3lab_research_v1/python 跑，但資料集路徑與主專案 SGLATrack-main 共用（勿再用他人機器上的絕對路徑）。
        # 控制 train / val / test 使用的 GPU（若專案其它處有讀取此欄位）
        self.cuda_visible_devices = "0"

        self.workspace_dir = '/home/junjie/01_Research/SGLATrack-main'
        self.tensorboard_dir = '/home/junjie/01_Research/SGLATrack-main/tensorboard'
        self.pretrained_networks = '/home/junjie/01_Research/SGLATrack-main/pretrained_networks'
        self.lasot_dir = '/home/junjie/01_Research/SGLATrack-main/data/lasot'
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
        self.uav123_10fps_dir = '/home/junjie/01_Research/SGLATrack-main/data/uav123_10fps/UAV123_10fps'
        self.uavtrack_dir = '/home/junjie/01_Research/SGLATrack-main/data/uavtrack112/home/data/V4RFlight112'
        self.uavdt_dir = '/home/junjie/01_Research/SGLATrack-main/data/uavdt/home/data/uavdt'
        self.dtb70_dir = '/home/junjie/01_Research/SGLATrack-main/data/dtb70/DTB70'
        self.visdrone_dir = '/home/junjie/01_Research/SGLATrack-main/data/visdrone/VisDrone2018-SOT-test-dev'
