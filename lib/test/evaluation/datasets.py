"""
Dataset name to dataset class mapping. Provides get_dataset() for testing/evaluation.
"""


def get_dataset(name):
    """Get evaluation dataset by name. Returns the sequence list (list of Sequence)."""
    name = name.lower().strip()

    if name == 'otb':
        from .otbdataset import OTBDataset
        return OTBDataset().get_sequence_list()
    elif name == 'nfs':
        from .nfsdataset import NFSDataset
        return NFSDataset().get_sequence_list()
    elif name == 'uav':
        from .uavdataset import UAVDataset
        return UAVDataset().get_sequence_list()
    elif name == 'uav123':
        from .uav123dataset import UAV123Dataset
        return UAV123Dataset().get_sequence_list()
    elif name == 'uav123_test':
        from .uav123_testdataset import UAV123TestDataset
        return UAV123TestDataset().get_sequence_list()
    elif name == 'uav123_10fps':
        from .uav123_10fpsdataset import UAV123_10fpsDataset
        return UAV123_10fpsDataset().get_sequence_list()
    elif name == 'lasot':
        from .lasotdataset import LaSOTDataset
        return LaSOTDataset().get_sequence_list()
    elif name == 'got10k' or name == 'gott':
        from .got10kdataset import GOT10KDataset
        return GOT10KDataset(split='test').get_sequence_list()
    elif name == 'gotv':
        from .got10kdataset import GOT10KDataset
        return GOT10KDataset(split='val').get_sequence_list()
    elif name == 'trackingnet' or name == 'tn':
        from .trackingnetdataset import TrackingNetDataset
        return TrackingNetDataset().get_sequence_list()
    elif name == 'tpl':
        from .tc128dataset import TC128Dataset
        return TC128Dataset().get_sequence_list()
    elif name == 'vot':
        from .votdataset import VOTDataset
        return VOTDataset().get_sequence_list()
    elif name == 'visdrone':
        from .visdronedataset import VISDRONEDataset
        return VISDRONEDataset().get_sequence_list()
    elif name == 'uavdt':
        from .uavdtdataset import UAVDTDataset
        return UAVDTDataset().get_sequence_list()
    elif name == 'dtb70':
        from .dtb70dataset import DTB70Dataset
        return DTB70Dataset().get_sequence_list()
    elif name == 'uavtrack':
        from .uavtrackdataset import UAVTrackDataset
        return UAVTrackDataset().get_sequence_list()
    elif name == 'uavtrack112':
        from .uavtrack112dataset import UAVTrack112Dataset
        return UAVTrack112Dataset().get_sequence_list()
    elif name == 'lasot_lmdb':
        from .lasot_lmdbdataset import LaSOTlmdbDataset
        return LaSOTlmdbDataset().get_sequence_list()
    elif name == 'tc128':
        from .tc128dataset import TC128Dataset
        return TC128Dataset().get_sequence_list()
    elif name == 'tc128ce':
        from .tc128cedataset import TC128CEDataset
        return TC128CEDataset().get_sequence_list()
    elif name == 'itb':
        from .itbdataset import ITBDataset
        return ITBDataset().get_sequence_list()
    elif name == 'tnl2k':
        from .tnl2kdataset import TNL2kDataset
        return TNL2kDataset().get_sequence_list()
    elif name == 'biodrone':
        from .biodronedataset import BioDroneataset
        return BioDroneataset().get_sequence_list()
    elif name == 'webuav3m':
        from .webuav3mdataset import WebUAV3MDataset
        return WebUAV3MDataset().get_sequence_list()
    elif name == 'lasot_extension_subset':
        from .lasotextensionsubsetdataset import LaSOTExtensionSubsetDataset
        return LaSOTExtensionSubsetDataset().get_sequence_list()
    else:
        raise ValueError(f"Unknown dataset: {name}")
