import torch
from torch.utils.data.distributed import DistributedSampler

from lib.train.dataset import Lasot, Got10k, MSCOCOSeq, ImagenetVID, TrackingNet, UAV123
from lib.train.dataset import UAV123_10FPS, UAVTrack, UAVTrack112, UAVDT, DTB70, VisDrone
from lib.train.dataset import Lasot_lmdb, Got10k_lmdb, MSCOCOSeq_lmdb, ImagenetVID_lmdb, TrackingNet_lmdb
from lib.train.data import sampler
from lib.train.data.image_loader import opencv_loader
from lib.train.data import processing
from lib.train.data.loader import LTRLoader
import lib.train.data.transforms as tfm


def update_settings(settings, cfg):
    settings.print_interval = cfg.TRAIN.PRINT_INTERVAL
    settings.search_area_factor = {'template': cfg.DATA.TEMPLATE.FACTOR,
                                  'search': cfg.DATA.SEARCH.FACTOR}
    settings.output_sz = {'template': cfg.DATA.TEMPLATE.SIZE,
                         'search': cfg.DATA.SEARCH.SIZE}
    settings.center_jitter_factor = {'template': cfg.DATA.TEMPLATE.CENTER_JITTER,
                                     'search': cfg.DATA.SEARCH.CENTER_JITTER}
    settings.scale_jitter_factor = {'template': cfg.DATA.TEMPLATE.SCALE_JITTER,
                                    'search': cfg.DATA.SEARCH.SCALE_JITTER}
    settings.grad_clip_norm = cfg.TRAIN.GRAD_CLIP_NORM
    settings.print_stats = None
    settings.batchsize = cfg.TRAIN.BATCH_SIZE
    settings.scheduler_type = cfg.TRAIN.SCHEDULER.TYPE


def names2datasets(name_list, settings, image_loader):
    assert isinstance(name_list, list)
    datasets = []
    allowed = ["LASOT", "GOT10K_vottrain", "GOT10K_votval", "GOT10K_train_full", "GOT10K_official_val",
               "COCO17", "VID", "TRACKINGNET",
               "UAV123", "UAV123_train", "UAV123_val",
               "UAV123_10FPS", "UAVTrack", "UAVTrack112", "UAVDT", "DTB70", "VisDrone"]
    for name in name_list:
        if name not in allowed:
            raise ValueError("Unknown dataset: {}".format(name))
        print("[Data] Building dataset: {} ...".format(name), flush=True)
        if name == "LASOT":
            if settings.use_lmdb:
                datasets.append(Lasot_lmdb(settings.env.lasot_lmdb_dir, split='train', image_loader=image_loader))
            else:
                datasets.append(Lasot(settings.env.lasot_dir, split='train', image_loader=image_loader))
        elif name == "GOT10K_vottrain":
            if settings.use_lmdb:
                datasets.append(Got10k_lmdb(settings.env.got10k_lmdb_dir, split='vottrain', image_loader=image_loader))
            else:
                datasets.append(Got10k(settings.env.got10k_dir, split='vottrain', image_loader=image_loader))
        elif name == "GOT10K_train_full":
            if settings.use_lmdb:
                datasets.append(Got10k_lmdb(settings.env.got10k_lmdb_dir, split='train_full', image_loader=image_loader))
            else:
                datasets.append(Got10k(settings.env.got10k_dir, split='train_full', image_loader=image_loader))
        elif name == "GOT10K_votval":
            if settings.use_lmdb:
                datasets.append(Got10k_lmdb(settings.env.got10k_lmdb_dir, split='votval', image_loader=image_loader))
            else:
                datasets.append(Got10k(settings.env.got10k_dir, split='votval', image_loader=image_loader))
        elif name == "GOT10K_official_val":
            datasets.append(Got10k(settings.env.got10k_val_dir, split=None, image_loader=image_loader))
        elif name == "COCO17":
            if settings.use_lmdb:
                datasets.append(MSCOCOSeq_lmdb(settings.env.coco_lmdb_dir, version="2017", image_loader=image_loader))
            else:
                datasets.append(MSCOCOSeq(settings.env.coco_dir, version="2017", image_loader=image_loader))
        elif name == "VID":
            if settings.use_lmdb:
                datasets.append(ImagenetVID_lmdb(settings.env.imagenet_lmdb_dir, image_loader=image_loader))
            else:
                datasets.append(ImagenetVID(settings.env.imagenet_dir, image_loader=image_loader))
        elif name == "TRACKINGNET":
            if settings.use_lmdb:
                datasets.append(TrackingNet_lmdb(settings.env.trackingnet_lmdb_dir, image_loader=image_loader))
            else:
                datasets.append(TrackingNet(settings.env.trackingnet_dir, image_loader=image_loader))
        elif name in ("UAV123", "UAV123_train", "UAV123_val"):
            split_map = {"UAV123": None, "UAV123_train": "train", "UAV123_val": "val"}
            datasets.append(UAV123(settings.env.uav123_dir, image_loader=image_loader, split=split_map[name]))
        elif name == "UAV123_10FPS":
            datasets.append(UAV123_10FPS(settings.env.uav123_10fps_dir, image_loader=image_loader, split=None))
        elif name == "UAVTrack":
            datasets.append(UAVTrack(settings.env.uavtrack_dir, image_loader=image_loader))
        elif name == "UAVTrack112":
            datasets.append(UAVTrack112(settings.env.uavtrack_dir, image_loader=image_loader))
        elif name == "UAVDT":
            datasets.append(UAVDT(settings.env.uavdt_dir, image_loader=image_loader))
        elif name == "DTB70":
            datasets.append(DTB70(settings.env.dtb70_dir, image_loader=image_loader))
        elif name == "VisDrone":
            datasets.append(VisDrone(settings.env.visdrone_dir, image_loader=image_loader))
        print("[Data]   {} done ({} sequences).".format(name, len(datasets[-1])), flush=True)
    return datasets


def build_dataloaders(cfg, settings):
    transform_joint = tfm.Transform(tfm.ToGrayscale(probability=0.05),
                                    tfm.RandomHorizontalFlip(probability=0.5))

    transform_train = tfm.Transform(tfm.ToTensorAndJitter(0.2),
                                    tfm.RandomHorizontalFlip_Norm(probability=0.5),
                                    tfm.Normalize(mean=cfg.DATA.MEAN, std=cfg.DATA.STD))

    transform_val = tfm.Transform(tfm.ToTensor(),
                                  tfm.Normalize(mean=cfg.DATA.MEAN, std=cfg.DATA.STD))

    output_sz = settings.output_sz
    search_area_factor = settings.search_area_factor

    data_processing_train = processing.STARKProcessing(
        search_area_factor=search_area_factor,
        output_sz=output_sz,
        center_jitter_factor=settings.center_jitter_factor,
        scale_jitter_factor=settings.scale_jitter_factor,
        mode='sequence',
        transform=transform_train,
        joint_transform=transform_joint,
        settings=settings)

    data_processing_val = processing.STARKProcessing(
        search_area_factor=search_area_factor,
        output_sz=output_sz,
        center_jitter_factor=settings.center_jitter_factor,
        scale_jitter_factor=settings.scale_jitter_factor,
        mode='sequence',
        transform=transform_val,
        joint_transform=transform_joint,
        settings=settings)

    settings.num_template = getattr(cfg.DATA.TEMPLATE, "NUMBER", 1)
    settings.num_search = getattr(cfg.DATA.SEARCH, "NUMBER", 1)
    sampler_mode = getattr(cfg.DATA, "SAMPLER_MODE", "causal")
    train_cls = getattr(cfg.TRAIN, "TRAIN_CLS", False)

    print("[Data] Building train sampler (this may take a while for GOT10K) ...", flush=True)
    dataset_train = sampler.TrackingSampler(
        datasets=names2datasets(cfg.DATA.TRAIN.DATASETS_NAME, settings, opencv_loader),
        p_datasets=cfg.DATA.TRAIN.DATASETS_RATIO,
        samples_per_epoch=cfg.DATA.TRAIN.SAMPLE_PER_EPOCH,
        max_gap=cfg.DATA.MAX_SAMPLE_INTERVAL,
        num_search_frames=settings.num_search,
        num_template_frames=settings.num_template,
        processing=data_processing_train,
        frame_sample_mode=sampler_mode,
        train_cls=train_cls)

    train_sampler = DistributedSampler(dataset_train) if settings.local_rank != -1 else None
    shuffle = False if settings.local_rank != -1 else True

    loader_train = LTRLoader('train', dataset_train, training=True, batch_size=cfg.TRAIN.BATCH_SIZE,
                             shuffle=shuffle, num_workers=cfg.TRAIN.NUM_WORKER, drop_last=True, stack_dim=1,
                             sampler=train_sampler)

    print("[Data] Building validation datasets ...", flush=True)
    dataset_val = sampler.TrackingSampler(
        datasets=names2datasets(cfg.DATA.VAL.DATASETS_NAME, settings, opencv_loader),
        p_datasets=cfg.DATA.VAL.DATASETS_RATIO,
        samples_per_epoch=cfg.DATA.VAL.SAMPLE_PER_EPOCH,
        max_gap=cfg.DATA.MAX_SAMPLE_INTERVAL,
        num_search_frames=settings.num_search,
        num_template_frames=settings.num_template,
        processing=data_processing_val,
        frame_sample_mode=sampler_mode,
        train_cls=train_cls)

    val_sampler = DistributedSampler(dataset_val) if settings.local_rank != -1 else None
    loader_val = LTRLoader('val', dataset_val, training=False, batch_size=cfg.TRAIN.BATCH_SIZE,
                           num_workers=cfg.TRAIN.NUM_WORKER, drop_last=True, stack_dim=1, sampler=val_sampler,
                           epoch_interval=cfg.TRAIN.VAL_EPOCH_INTERVAL)

    print("[Data] Train/val loaders ready.", flush=True)
    return loader_train, loader_val


def get_optimizer_scheduler(net, cfg):
    train_cls = getattr(cfg.TRAIN, "TRAIN_CLS", False)
    lr_backbone = getattr(cfg.TRAIN, "LR_BACKBONE", None)
    lr_val = float(cfg.TRAIN.LR)

    if train_cls:
        param_dicts = [
            {"params": [p for n, p in net.named_parameters() if "cls" in n and p.requires_grad]}
        ]
        for n, p in net.named_parameters():
            if "cls" not in n:
                p.requires_grad = False
    else:
        backbone_params = [p for n, p in net.named_parameters() if "backbone" in n and p.requires_grad]
        other_params = [p for n, p in net.named_parameters() if "backbone" not in n and p.requires_grad]

        lr_bb = float(lr_backbone) if lr_backbone is not None else lr_val * float(cfg.TRAIN.BACKBONE_MULTIPLIER)
        param_dicts = [
            {"params": other_params},
            {"params": backbone_params, "lr": lr_bb},
        ]

    if cfg.TRAIN.OPTIMIZER == "ADAMW":
        optimizer = torch.optim.AdamW(param_dicts, lr=lr_val, weight_decay=float(cfg.TRAIN.WEIGHT_DECAY))
    else:
        raise ValueError("Unsupported Optimizer")

    if cfg.TRAIN.SCHEDULER.TYPE == 'step':
        lr_scheduler = torch.optim.lr_scheduler.StepLR(
            optimizer, int(cfg.TRAIN.LR_DROP_EPOCH), gamma=float(cfg.TRAIN.SCHEDULER.DECAY_RATE))
    elif cfg.TRAIN.SCHEDULER.TYPE == "Mstep":
        ms = cfg.TRAIN.SCHEDULER.MILESTONES
        milestones = [int(m) for m in ms] if isinstance(ms, (list, tuple)) else [int(ms)]
        lr_scheduler = torch.optim.lr_scheduler.MultiStepLR(
            optimizer, milestones=milestones, gamma=float(cfg.TRAIN.SCHEDULER.GAMMA))
    else:
        raise ValueError("Unsupported scheduler")
    return optimizer, lr_scheduler
