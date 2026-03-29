"""
UAV123 test split for evaluation (uses test_split.txt from create_uav123_split).
Full 30fps, uav123_path, seq.dataset='uav123_test'.
"""
import os
import numpy as np
from lib.test.evaluation.data import Sequence, BaseDataset, SequenceList
from lib.test.utils.load_text import load_text


def _get_uav123_full_sequence_info():
    """Full 30fps sequence info - path data_seq/UAV123, ~3x frames from 10fps."""
    infos = [
        ('bike1', 'bike1', 1, 3085), ('bike2', 'bike2', 1, 553), ('bike3', 'bike3', 1, 433),
        ('bird1_1', 'bird1', 1, 253), ('bird1_2', 'bird1', 775, 1477), ('bird1_3', 'bird1', 1573, 2437),
        ('boat1', 'boat1', 1, 901), ('boat2', 'boat2', 1, 799), ('boat3', 'boat3', 1, 901),
        ('boat4', 'boat4', 1, 553), ('boat5', 'boat5', 1, 505), ('boat6', 'boat6', 1, 805),
        ('boat7', 'boat7', 1, 535), ('boat8', 'boat8', 1, 685), ('boat9', 'boat9', 1, 1399),
        ('building1', 'building1', 1, 469), ('building2', 'building2', 1, 577),
        ('building3', 'building3', 1, 829), ('building4', 'building4', 1, 787),
        ('building5', 'building5', 1, 481),
        ('car1_1', 'car1', 1, 751), ('car1_2', 'car1', 751, 1627), ('car1_3', 'car1', 1627, 2629),
        ('car2', 'car2', 1, 1321), ('car3', 'car3', 1, 1717), ('car4', 'car4', 1, 1345),
        ('car5', 'car5', 1, 745), ('car6_1', 'car6', 1, 487), ('car6_2', 'car6', 487, 1807),
        ('car6_3', 'car6', 1807, 2953), ('car6_4', 'car6', 2953, 3925), ('car6_5', 'car6', 3925, 4861),
        ('car7', 'car7', 1, 1033), ('car8_1', 'car8', 1, 1357), ('car8_2', 'car8', 1357, 2575),
        ('car9', 'car9', 1, 1879), ('car10', 'car10', 1, 1405), ('car11', 'car11', 1, 337),
        ('car12', 'car12', 1, 499), ('car13', 'car13', 1, 415), ('car14', 'car14', 1, 1327),
        ('car15', 'car15', 1, 469), ('car16_1', 'car16', 1, 415), ('car16_2', 'car16', 415, 1993),
        ('car17', 'car17', 1, 1057), ('car18', 'car18', 1, 1207),
        ('car1_s', 'car1_s', 1, 1475), ('car2_s', 'car2_s', 1, 320), ('car3_s', 'car3_s', 1, 1300),
        ('car4_s', 'car4_s', 1, 830), ('car5', 'car5', 1, 745),
        ('group1_1', 'group1', 1, 1333), ('group1_2', 'group1', 1333, 2515),
        ('group1_3', 'group1', 2515, 3925), ('group1_4', 'group1', 3925, 4873),
        ('group2_1', 'group2', 1, 907), ('group2_2', 'group2', 907, 1771),
        ('group2_3', 'group2', 1771, 2683),
        ('group3_1', 'group3', 1, 1567), ('group3_2', 'group3', 1567, 2827),
        ('group3_3', 'group3', 2827, 4369), ('group3_4', 'group3', 4369, 5527),
        ('person1', 'person1', 1, 799), ('person2_1', 'person2', 1, 1189), ('person2_2', 'person2', 1189, 2623),
        ('person3', 'person3', 1, 643), ('person4_1', 'person4', 1, 1501), ('person4_2', 'person4', 1501, 2743),
        ('person5_1', 'person5', 1, 877), ('person5_2', 'person5', 877, 2101),
        ('person6', 'person6', 1, 901), ('person7_1', 'person7', 1, 1249), ('person7_2', 'person7', 1249, 2065),
        ('person8_1', 'person8', 1, 1075), ('person8_2', 'person8', 1075, 1525),
        ('person9', 'person9', 1, 661), ('person10', 'person10', 1, 1021), ('person11', 'person11', 1, 721),
        ('person12_1', 'person12', 1, 601), ('person12_2', 'person12', 601, 1621),
        ('person13', 'person13', 1, 883), ('person14_1', 'person14', 1, 847),
        ('person14_2', 'person14', 847, 1813), ('person14_3', 'person14', 1813, 2923),
        ('person15', 'person15', 1, 1339), ('person16', 'person16', 1, 1147),
        ('person17_1', 'person17', 1, 1501), ('person17_2', 'person17', 1501, 2347),
        ('person18', 'person18', 1, 1393), ('person19_1', 'person19', 1, 1243),
        ('person19_2', 'person19', 1243, 2791), ('person19_3', 'person19', 2791, 4357),
        ('person20', 'person20', 1, 1783), ('person21', 'person21', 1, 487),
        ('person22', 'person22', 1, 199), ('person23', 'person23', 1, 397),
        ('person1_s', 'person1_s', 1, 1600), ('person2_s', 'person2_s', 1, 250),
        ('person3_s', 'person3_s', 1, 505),
        ('truck1', 'truck1', 1, 463), ('truck2', 'truck2', 1, 385), ('truck3', 'truck3', 1, 535),
        ('truck4_1', 'truck4', 1, 577), ('truck4_2', 'truck4', 577, 1261),
        ('uav1_1', 'uav1', 1, 1555), ('uav1_2', 'uav1', 1555, 2377), ('uav1_3', 'uav1', 2473, 3469),
        ('uav2', 'uav2', 1, 133), ('uav3', 'uav3', 1, 265), ('uav4', 'uav4', 1, 157),
        ('uav5', 'uav5', 1, 139), ('uav6', 'uav6', 1, 109), ('uav7', 'uav7', 1, 373),
        ('uav8', 'uav8', 1, 301),
        ('wakeboard1', 'wakeboard1', 1, 421), ('wakeboard2', 'wakeboard2', 1, 733),
        ('wakeboard3', 'wakeboard3', 1, 823), ('wakeboard4', 'wakeboard4', 1, 697),
        ('wakeboard5', 'wakeboard5', 1, 1675), ('wakeboard6', 'wakeboard6', 1, 1165),
        ('wakeboard7', 'wakeboard7', 1, 199), ('wakeboard8', 'wakeboard8', 1, 1543),
        ('wakeboard9', 'wakeboard9', 1, 355), ('wakeboard10', 'wakeboard10', 1, 469),
    ]
    return [{'name': n, 'path': f'data_seq/UAV123/{f}', 'startFrame': s, 'endFrame': e,
             'nz': 6, 'ext': 'jpg', 'anno_path': f'anno/UAV123/{n}.txt', 'object_class': 'object'}
            for n, f, s, e in infos]


class UAV123TestDataset(BaseDataset):
    """UAV123 test split (test_split.txt). Full 30fps, results under uav123_test/."""
    def __init__(self):
        super().__init__()
        self.base_path = self.env_settings.uav123_path
        all_infos = _get_uav123_full_sequence_info()
        test_names = self._load_test_split()
        if test_names:
            self.sequence_info_list = [s for s in all_infos if s['name'] in test_names]
        else:
            self.sequence_info_list = all_infos

    def _load_test_split(self):
        split_file = os.path.join(self.base_path, 'test_split.txt')
        if not os.path.isfile(split_file):
            return set()
        with open(split_file, 'r') as f:
            return set(line.strip() for line in f if line.strip())

    def get_sequence_list(self):
        return SequenceList([self._construct_sequence(s) for s in self.sequence_info_list])

    def _construct_sequence(self, seq_info):
        frames = [
            '{}/{}/{frame:06d}.jpg'.format(self.base_path, seq_info['path'], frame=frame_num)
            for frame_num in range(seq_info['startFrame'], seq_info['endFrame'] + 1)
        ]
        anno_path = os.path.join(self.base_path, seq_info['anno_path'])
        gt = load_text(anno_path, delimiter=',', dtype=np.float64, backend='numpy')
        return Sequence(seq_info['name'], frames, 'uav123_test', gt, object_class=seq_info['object_class'])

    def __len__(self):
        return len(self.sequence_info_list)
