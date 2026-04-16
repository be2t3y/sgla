import random
import zlib

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
from lib.utils.misc import is_main_process


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


_UAV50_BASES = frozenset({
    "UAV123", "UAV123_10FPS", "UAVTrack", "UAVTrack112", "UAVDT", "DTB70",
})


def _uav50_split_sequence_names(names, seed, salt):
    names = sorted(names)
    if len(names) == 0:
        return [], []
    if len(names) == 1:
        return names, []
    rng = random.Random((int(seed) + zlib.adler32(salt.encode("utf-8"))) % (2 ** 32))
    order = names[:]
    rng.shuffle(order)
    n = len(order) // 2
    return order[:n], order[n:]


def _collect_uav_sequence_names(base, settings, image_loader):
    if base == "UAV123":
        d = UAV123(settings.env.uav123_dir, image_loader=image_loader, split=None)
    elif base == "UAV123_10FPS":
        d = UAV123_10FPS(settings.env.uav123_10fps_dir, image_loader=image_loader, split=None)
    elif base == "UAVTrack":
        d = UAVTrack(settings.env.uavtrack_dir, image_loader=image_loader)
    elif base == "UAVTrack112":
        d = UAVTrack112(settings.env.uavtrack_dir, image_loader=image_loader)
    elif base == "UAVDT":
        d = UAVDT(settings.env.uavdt_dir, image_loader=image_loader)
    elif base == "DTB70":
        d = DTB70(settings.env.dtb70_dir, image_loader=image_loader)
    else:
        raise ValueError("Unknown UAV base: {}".format(base))
    return list(d.sequence_list)


def _parse_uav50_dataset_name(name):
    if name.endswith("_T50"):
        return name[:-4], "train"
    if name.endswith("_V50"):
        return name[:-4], "val"
    return None, None


def _build_uav50_dataset(name, settings, image_loader, cfg):
    base, part = _parse_uav50_dataset_name(name)
    if base is None or base not in _UAV50_BASES:
        raise ValueError("Invalid UAV 50/50 dataset name: {}".format(name))
    if cfg is None:
        raise ValueError("Dataset {} requires cfg (for DATA.MIXED_UAV_SPLIT_SEED).".format(name))
    seed = getattr(cfg.DATA, "MIXED_UAV_SPLIT_SEED", 42)
    all_names = _collect_uav_sequence_names(base, settings, image_loader)
    tr, va = _uav50_split_sequence_names(all_names, seed, base)
    subset = set(tr if part == "train" else va)
    if len(subset) == 0:
        print("[Data] Warning: {} has 0 sequences after 50/50 split.".format(name), flush=True)
    if base == "UAV123":
        return UAV123(settings.env.uav123_dir, image_loader=image_loader, split=None, sequence_subset=subset)
    if base == "UAV123_10FPS":
        return UAV123_10FPS(settings.env.uav123_10fps_dir, image_loader=image_loader, split=None,
                            sequence_subset=subset)
    if base == "UAVTrack":
        return UAVTrack(settings.env.uavtrack_dir, image_loader=image_loader, sequence_subset=subset)
    if base == "UAVTrack112":
        return UAVTrack112(settings.env.uavtrack_dir, image_loader=image_loader, sequence_subset=subset)
    if base == "UAVDT":
        return UAVDT(settings.env.uavdt_dir, image_loader=image_loader, sequence_subset=subset)
    if base == "DTB70":
        return DTB70(settings.env.dtb70_dir, image_loader=image_loader, sequence_subset=subset)
    raise ValueError(base)


def _normalize_sampling_probs(p_cfg, datasets):
    if p_cfg is None:
        return None
    if isinstance(p_cfg, str) and p_cfg.lower() in ("by_size", "auto", "proportional"):
        return [len(d) for d in datasets]
    return p_cfg


def names2datasets(name_list, settings, image_loader, cfg=None):
    assert isinstance(name_list, list)
    datasets = []
    allowed = ["LASOT", "GOT10K_vottrain", "GOT10K_votval", "GOT10K_train_full", "GOT10K_official_val",
               "COCO17", "VID", "TRACKINGNET",
               "UAV123", "UAV123_train", "UAV123_val",
               "UAV123_10FPS", "UAVTrack", "UAVTrack112", "UAVDT", "DTB70", "VisDrone"]
    for name in name_list:
        uav_base, _ = _parse_uav50_dataset_name(name)
        if uav_base is not None and uav_base in _UAV50_BASES:
            print("[Data] Building dataset: {} ...".format(name), flush=True)
            datasets.append(_build_uav50_dataset(name, settings, image_loader, cfg))
            print("[Data]   {} done ({} sequences).".format(name, len(datasets[-1])), flush=True)
            continue
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

    train_tfms = [
        tfm.ToTensorAndJitter(0.2),
        tfm.RandomHorizontalFlip_Norm(probability=0.5),
        tfm.Normalize(mean=cfg.DATA.MEAN, std=cfg.DATA.STD),
    ]
    ra = getattr(cfg.DATA, "RAND_AUGMENT", None)
    if ra is not None and bool(getattr(ra, "ENABLE", False)):
        train_tfms.insert(
            0,
            tfm.RandAugmentColor(
                num_ops=int(getattr(ra, "NUM_OPS", 2)),
                magnitude=int(getattr(ra, "MAGNITUDE", 9)),
                probability=float(getattr(ra, "PROB", 0.7)),
            ),
        )
        print(
            "[Data] RandAugmentColor: num_ops={}, magnitude={}, prob={}.".format(
                getattr(ra, "NUM_OPS", 2),
                getattr(ra, "MAGNITUDE", 9),
                getattr(ra, "PROB", 0.7),
            ),
            flush=True,
        )
    transform_train = tfm.Transform(*train_tfms)

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
    train_datasets = names2datasets(cfg.DATA.TRAIN.DATASETS_NAME, settings, opencv_loader, cfg)
    train_p = _normalize_sampling_probs(cfg.DATA.TRAIN.DATASETS_RATIO, train_datasets)
    dataset_train = sampler.TrackingSampler(
        datasets=train_datasets,
        p_datasets=train_p,
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
    val_datasets = names2datasets(cfg.DATA.VAL.DATASETS_NAME, settings, opencv_loader, cfg)
    val_p = _normalize_sampling_probs(cfg.DATA.VAL.DATASETS_RATIO, val_datasets)
    dataset_val = sampler.TrackingSampler(
        datasets=val_datasets,
        p_datasets=val_p,
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
    if train_cls:
        if is_main_process():
            print("Only training classification head. Learnable parameters are shown below.")
        param_dicts = [
            {"params": [p for n, p in net.named_parameters() if "cls" in n and p.requires_grad]}
        ]

        for n, p in net.named_parameters():
            if "cls" not in n:
                p.requires_grad = False
            elif is_main_process():
                print(n)
    else:
        lr_base = cfg.TRAIN.LR
        lr_bb_cfg = getattr(cfg.TRAIN, "LR_BACKBONE", None)
        if lr_bb_cfg is not None:
            lr_backbone = float(lr_bb_cfg[0] if isinstance(lr_bb_cfg, (list, tuple)) else lr_bb_cfg)
        else:
            bb_mult = cfg.TRAIN.BACKBONE_MULTIPLIER
            bb_mult = float(bb_mult[0] if isinstance(bb_mult, (list, tuple)) else bb_mult)
            lr_base = float(lr_base[0] if isinstance(lr_base, (list, tuple)) else lr_base)
            lr_backbone = lr_base * bb_mult

        param_dicts = [
            {"params": [p for n, p in net.named_parameters() if "backbone" not in n and p.requires_grad]},
            {
                "params": [p for n, p in net.named_parameters() if "backbone" in n and p.requires_grad],
                "lr": lr_backbone,
            },
        ]
        if is_main_process():
            print("Learnable parameters are shown below.")
            for n, p in net.named_parameters():
                if p.requires_grad:
                    print(n)

    lr_main = cfg.TRAIN.LR
    lr_main = float(lr_main[0] if isinstance(lr_main, (list, tuple)) else lr_main)
    if cfg.TRAIN.OPTIMIZER == "ADAMW":
        optimizer = torch.optim.AdamW(param_dicts, lr=lr_main, weight_decay=float(cfg.TRAIN.WEIGHT_DECAY))
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
