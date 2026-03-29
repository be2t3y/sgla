"""
UAV123 evaluation dataset (30fps, uses uav123_path).
"""
from .uavdataset import UAVDataset


class UAV123Dataset(UAVDataset):
    """UAV123 dataset using uav123_path (standard data/uav123/UAV123 structure)."""
    def __init__(self):
        super().__init__()
        self.base_path = self.env_settings.uav123_path

    def _construct_sequence(self, sequence_info):
        seq = super()._construct_sequence(sequence_info)
        seq.dataset = 'uav123'
        return seq
