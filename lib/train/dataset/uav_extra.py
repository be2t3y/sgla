"""
Additional UAV-related video datasets for training.

These datasets are originally used as evaluation benchmarks in this repo, but can also be
sampled as training video datasets (sequence mode) as long as the directory structure
and annotations are present.
"""

import glob
import os
import random
from collections import OrderedDict

import numpy as np
import torch

from .base_video_dataset import BaseVideoDataset
from lib.train.data.image_loader import jpeg4py_loader_w_failsafe
from lib.train.admin import env_settings


def _read_bbox_txt(path: str, delimiter: str = ',', dtype=np.float32) -> torch.Tensor:
    if not os.path.exists(path):
        raise FileNotFoundError(path)
    arr = np.loadtxt(path, delimiter=delimiter).astype(dtype, copy=False)
    if arr.ndim == 1:
        arr = arr.reshape(1, -1)
    arr = np.nan_to_num(arr, nan=0.0)
    return torch.tensor(arr[:, :4], dtype=torch.float32)


class _FolderVideoDataset(BaseVideoDataset):
    """Generic folder-based video dataset for training."""

    def __init__(self, name, root, image_loader=jpeg4py_loader_w_failsafe, data_fraction=None):
        super().__init__(name, root, image_loader)
        self.sequence_list = self._build_sequence_list()

        if data_fraction is not None:
            self.sequence_list = random.sample(
                self.sequence_list, max(1, int(len(self.sequence_list) * data_fraction)))

        self.seq_per_class = self._build_seq_per_class()
        self.class_list = list(self.seq_per_class.keys())

    def _build_sequence_list(self):
        raise NotImplementedError

    def _build_seq_per_class(self):
        d = {}
        for i, name in enumerate(self.sequence_list):
            cls = name.split('_')[0]
            d.setdefault(cls, []).append(i)
        return d

    def get_name(self):
        return self.name.lower()

    def has_class_info(self):
        return True

    def get_num_sequences(self):
        return len(self.sequence_list)

    def get_sequences_in_class(self, class_name):
        return self.seq_per_class.get(class_name, [])

    def get_sequence_info(self, seq_id):
        bbox = self._read_bb_anno(self.sequence_list[seq_id])
        valid = (bbox[:, 2] > 0) & (bbox[:, 3] > 0)
        visible = valid.clone().byte()
        return {'bbox': bbox, 'valid': valid, 'visible': visible}

    def _read_bb_anno(self, seq_name):
        raise NotImplementedError

    def _get_frame_list(self, seq_name):
        raise NotImplementedError

    def get_frames(self, seq_id, frame_ids, anno=None):
        seq_name = self.sequence_list[seq_id]
        frames = self._get_frame_list(seq_name)
        frame_list = [self.image_loader(frames[f]) for f in frame_ids]

        if anno is None:
            anno = self.get_sequence_info(seq_id)

        anno_frames = {k: [v[f_id, ...].clone() for f_id in frame_ids] for k, v in anno.items()}

        meta = OrderedDict({
            'object_class_name': 'object',
            'motion_class': None, 'major_class': None, 'root_class': None, 'motion_adverb': None,
        })
        return frame_list, anno_frames, meta


class UAV123_10FPS(BaseVideoDataset):
    """UAV123 10fps variant for training.

    Uses the same sequence definitions as the evaluation dataset with folder mapping.
    """

    def __init__(self, root=None, image_loader=jpeg4py_loader_w_failsafe, split=None, data_fraction=None):
        root = env_settings().uav123_10fps_dir if root is None else root
        super().__init__('UAV123_10FPS', root, image_loader)
        self.split = split
        self.seq_info_list = self._get_uav123_10fps_sequence_info()
        self.sequence_list = self._build_sequence_list()

        if data_fraction is not None:
            self.sequence_list = random.sample(
                self.sequence_list, max(1, int(len(self.sequence_list) * data_fraction)))

        self.seq_per_class = self._build_seq_per_class()
        self.class_list = list(self.seq_per_class.keys())

    @staticmethod
    def _get_uav123_10fps_sequence_info():
        # (name, folder, startFrame, endFrame)
        infos = [
            ('bike1', 'bike1', 1, 1029), ('bike2', 'bike2', 1, 185), ('bike3', 'bike3', 1, 145),
            ('bird1_1', 'bird1', 1, 85), ('bird1_2', 'bird1', 259, 493), ('bird1_3', 'bird1', 525, 813),
            ('boat1', 'boat1', 1, 301), ('boat2', 'boat2', 1, 267), ('boat3', 'boat3', 1, 301),
            ('boat4', 'boat4', 1, 185), ('boat5', 'boat5', 1, 169), ('boat6', 'boat6', 1, 269),
            ('boat7', 'boat7', 1, 179), ('boat8', 'boat8', 1, 229), ('boat9', 'boat9', 1, 467),
            ('building1', 'building1', 1, 157), ('building2', 'building2', 1, 193),
            ('building3', 'building3', 1, 277), ('building4', 'building4', 1, 263),
            ('building5', 'building5', 1, 161),
            ('car1_1', 'car1', 1, 251), ('car1_2', 'car1', 251, 543), ('car1_3', 'car1', 543, 877),
            ('car2', 'car2', 1, 441), ('car3', 'car3', 1, 573), ('car4', 'car4', 1, 449),
            ('car5', 'car5', 1, 249), ('car6_1', 'car6', 1, 163), ('car6_2', 'car6', 163, 603),
            ('car6_3', 'car6', 603, 985), ('car6_4', 'car6', 985, 1309), ('car6_5', 'car6', 1309, 1621),
            ('car7', 'car7', 1, 345), ('car8_1', 'car8', 1, 453), ('car8_2', 'car8', 453, 859),
            ('car9', 'car9', 1, 627), ('car10', 'car10', 1, 469), ('car11', 'car11', 1, 113),
            ('car12', 'car12', 1, 167), ('car13', 'car13', 1, 139), ('car14', 'car14', 1, 443),
            ('car15', 'car15', 1, 157), ('car16_1', 'car16', 1, 139), ('car16_2', 'car16', 139, 665),
            ('car17', 'car17', 1, 353), ('car18', 'car18', 1, 403),
            ('group1_1', 'group1', 1, 445), ('group1_2', 'group1', 445, 839),
            ('group1_3', 'group1', 839, 1309), ('group1_4', 'group1', 1309, 1625),
            ('group2_1', 'group2', 1, 303), ('group2_2', 'group2', 303, 591), ('group2_3', 'group2', 591, 895),
            ('group3_1', 'group3', 1, 523), ('group3_2', 'group3', 523, 943),
            ('group3_3', 'group3', 943, 1457), ('group3_4', 'group3', 1457, 1843),
            ('person1', 'person1', 1, 267), ('person2_1', 'person2', 1, 397), ('person2_2', 'person2', 397, 875),
            ('person3', 'person3', 1, 215), ('person4_1', 'person4', 1, 501), ('person4_2', 'person4', 501, 915),
            ('person5_1', 'person5', 1, 293), ('person5_2', 'person5', 293, 701),
            ('person6', 'person6', 1, 301), ('person7_1', 'person7', 1, 417), ('person7_2', 'person7', 417, 689),
            ('person8_1', 'person8', 1, 359), ('person8_2', 'person8', 359, 509),
            ('person9', 'person9', 1, 221), ('person10', 'person10', 1, 341), ('person11', 'person11', 1, 241),
            ('person12_1', 'person12', 1, 201), ('person12_2', 'person12', 201, 541),
            ('person13', 'person13', 1, 295), ('person14_1', 'person14', 1, 283),
            ('person14_2', 'person14', 283, 605), ('person14_3', 'person14', 605, 975),
            ('person15', 'person15', 1, 447), ('person16', 'person16', 1, 383),
            ('person17_1', 'person17', 1, 501), ('person17_2', 'person17', 501, 783),
            ('person18', 'person18', 1, 465), ('person19_1', 'person19', 1, 415),
            ('person19_2', 'person19', 415, 931), ('person19_3', 'person19', 931, 1453),
            ('person20', 'person20', 1, 595), ('person21', 'person21', 1, 163),
            ('person22', 'person22', 1, 67), ('person23', 'person23', 1, 133),
            ('truck1', 'truck1', 1, 155), ('truck2', 'truck2', 1, 129), ('truck3', 'truck3', 1, 179),
            ('truck4_1', 'truck4', 1, 193), ('truck4_2', 'truck4', 193, 421),
            ('uav1_1', 'uav1', 1, 519), ('uav1_2', 'uav1', 519, 793), ('uav1_3', 'uav1', 825, 1157),
            ('uav2', 'uav2', 1, 45), ('uav3', 'uav3', 1, 89), ('uav4', 'uav4', 1, 53),
            ('uav5', 'uav5', 1, 47), ('uav6', 'uav6', 1, 37), ('uav7', 'uav7', 1, 125),
            ('uav8', 'uav8', 1, 101),
            ('wakeboard1', 'wakeboard1', 1, 141), ('wakeboard2', 'wakeboard2', 1, 245),
            ('wakeboard3', 'wakeboard3', 1, 275), ('wakeboard4', 'wakeboard4', 1, 233),
            ('wakeboard5', 'wakeboard5', 1, 559), ('wakeboard6', 'wakeboard6', 1, 389),
            ('wakeboard7', 'wakeboard7', 1, 67), ('wakeboard8', 'wakeboard8', 1, 515),
            ('wakeboard9', 'wakeboard9', 1, 119), ('wakeboard10', 'wakeboard10', 1, 157),
            ('car1_s', 'car1_s', 1, 492), ('car2_s', 'car2_s', 1, 107), ('car3_s', 'car3_s', 1, 434),
            ('car4_s', 'car4_s', 1, 277), ('person1_s', 'person1_s', 1, 534),
            ('person2_s', 'person2_s', 1, 84), ('person3_s', 'person3_s', 1, 169),
        ]
        out = []
        for name, folder, start, end in infos:
            out.append({
                'name': name,
                'path': f'data_seq/UAV123_10fps/{folder}',
                'startFrame': start,
                'endFrame': end,
                'ext': 'jpg',
                'anno_path': f'anno/UAV123_10fps/{name}.txt',
                'object_class': 'object',
            })
        return out

    def _build_sequence_list(self):
        if self.split is not None:
            split_file = os.path.join(self.root, f'{self.split}_split.txt')
            if os.path.exists(split_file):
                with open(split_file, 'r') as f:
                    valid = set(line.strip() for line in f if line.strip())
                names = [s['name'] for s in self.seq_info_list if s['name'] in valid]
                if names:
                    return names
        return [s['name'] for s in self.seq_info_list]

    def _build_seq_per_class(self):
        d = {}
        for i, name in enumerate(self.sequence_list):
            cls = name.split('_')[0]
            d.setdefault(cls, []).append(i)
        return d

    def get_name(self):
        return 'uav123_10fps'

    def has_class_info(self):
        return True

    def get_num_sequences(self):
        return len(self.sequence_list)

    def get_sequences_in_class(self, class_name):
        return self.seq_per_class.get(class_name, [])

    def _get_seq_info(self, seq_id):
        name = self.sequence_list[seq_id]
        for s in self.seq_info_list:
            if s['name'] == name:
                return s
        raise KeyError(name)

    def _read_bb_anno(self, seq_name):
        path = os.path.join(self.root, 'anno', 'UAV123_10fps', seq_name + '.txt')
        return _read_bbox_txt(path, delimiter=',')

    def get_sequence_info(self, seq_id):
        bbox = self._read_bb_anno(self.sequence_list[seq_id])
        valid = (bbox[:, 2] > 0) & (bbox[:, 3] > 0)
        visible = valid.clone().byte()
        return {'bbox': bbox, 'valid': valid, 'visible': visible}

    def _get_frame_path(self, seq_id, frame_id):
        info = self._get_seq_info(seq_id)
        fn = info['startFrame'] + frame_id
        return os.path.join(self.root, info['path'], f'{fn:06d}.{info["ext"]}')

    def get_frames(self, seq_id, frame_ids, anno=None):
        frame_list = [self.image_loader(self._get_frame_path(seq_id, f)) for f in frame_ids]
        if anno is None:
            anno = self.get_sequence_info(seq_id)
        anno_frames = {k: [v[f_id, ...].clone() for f_id in frame_ids] for k, v in anno.items()}
        meta = OrderedDict({
            'object_class_name': 'object',
            'motion_class': None, 'major_class': None, 'root_class': None, 'motion_adverb': None,
        })
        return frame_list, anno_frames, meta


class UAVTrack(_FolderVideoDataset):
    def __init__(self, root=None, image_loader=jpeg4py_loader_w_failsafe, data_fraction=None):
        root = env_settings().uavtrack_dir if root is None else root
        super().__init__('UAVTrack', root, image_loader=image_loader, data_fraction=data_fraction)

    def _build_sequence_list(self):
        seq_path = os.path.join(self.root, 'anno_l')
        return sorted([p[:-4] for p in os.listdir(seq_path) if p.endswith('.txt')])

    def _read_bb_anno(self, seq_name):
        return _read_bbox_txt(os.path.join(self.root, 'anno_l', f'{seq_name}.txt'), delimiter=',')

    def _get_frame_list(self, seq_name):
        frames_path = os.path.join(self.root, 'data_seq', seq_name)
        return sorted(glob.glob(os.path.join(frames_path, '*.jpg')))


class UAVTrack112(_FolderVideoDataset):
    def __init__(self, root=None, image_loader=jpeg4py_loader_w_failsafe, data_fraction=None):
        root = env_settings().uavtrack_dir if root is None else root
        super().__init__('UAVTrack112', root, image_loader=image_loader, data_fraction=data_fraction)

    def _build_sequence_list(self):
        seq_path = os.path.join(self.root, 'anno')
        return sorted([p[:-4] for p in os.listdir(seq_path) if p.endswith('.txt')])

    def _read_bb_anno(self, seq_name):
        return _read_bbox_txt(os.path.join(self.root, 'anno', f'{seq_name}.txt'), delimiter=',')

    def _get_frame_list(self, seq_name):
        frames_path = os.path.join(self.root, 'data_seq', seq_name)
        return sorted(glob.glob(os.path.join(frames_path, '*.jpg')))


class UAVDT(_FolderVideoDataset):
    def __init__(self, root=None, image_loader=jpeg4py_loader_w_failsafe, data_fraction=None):
        root = env_settings().uavdt_dir if root is None else root
        super().__init__('UAVDT', root, image_loader=image_loader, data_fraction=data_fraction)

    def _build_sequence_list(self):
        seq_path = os.path.join(self.root, 'sequences')
        return sorted([d for d in os.listdir(seq_path) if os.path.isdir(os.path.join(seq_path, d))])

    def _read_bb_anno(self, seq_name):
        return _read_bbox_txt(os.path.join(self.root, 'anno', f'{seq_name}_gt.txt'), delimiter=',')

    def _get_frame_list(self, seq_name):
        frames_path = os.path.join(self.root, 'sequences', seq_name)
        frames = [f for f in os.listdir(frames_path) if f.endswith('.jpg')]
        frames.sort(key=lambda f: int(f[3:-4]) if f.startswith('img') else int(os.path.splitext(f)[0]))
        return [os.path.join(frames_path, f) for f in frames]


class DTB70(_FolderVideoDataset):
    def __init__(self, root=None, image_loader=jpeg4py_loader_w_failsafe, data_fraction=None):
        root = env_settings().dtb70_dir if root is None else root
        super().__init__('DTB70', root, image_loader=image_loader, data_fraction=data_fraction)

    def _build_sequence_list(self):
        return sorted([d for d in os.listdir(self.root) if os.path.isdir(os.path.join(self.root, d))])

    def _read_bb_anno(self, seq_name):
        return _read_bbox_txt(os.path.join(self.root, seq_name, 'groundtruth_rect.txt'), delimiter=',')

    def _get_frame_list(self, seq_name):
        frames_path = os.path.join(self.root, seq_name, 'img')
        frames = [f for f in os.listdir(frames_path) if f.endswith('.jpg')]
        frames.sort(key=lambda f: int(os.path.splitext(f)[0]))
        return [os.path.join(frames_path, f) for f in frames]


class VisDrone(_FolderVideoDataset):
    def __init__(self, root=None, image_loader=jpeg4py_loader_w_failsafe, data_fraction=None):
        root = env_settings().visdrone_dir if root is None else root
        super().__init__('VisDrone', root, image_loader=image_loader, data_fraction=data_fraction)

    def _build_sequence_list(self):
        seq_path = os.path.join(self.root, 'sequences')
        return sorted([d for d in os.listdir(seq_path) if os.path.isdir(os.path.join(seq_path, d))])

    def _read_bb_anno(self, seq_name):
        return _read_bbox_txt(os.path.join(self.root, 'annotations', f'{seq_name}.txt'), delimiter=',')

    def _get_frame_list(self, seq_name):
        frames_path = os.path.join(self.root, 'sequences', seq_name)
        frames = [f for f in os.listdir(frames_path) if f.endswith('.jpg')]
        frames.sort(key=lambda f: int(f[3:-4]) if f.startswith('img') else int(os.path.splitext(f)[0]))
        return [os.path.join(frames_path, f) for f in frames]

