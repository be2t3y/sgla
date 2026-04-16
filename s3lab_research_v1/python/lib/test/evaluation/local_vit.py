from lib.test.evaluation.environment import EnvSettings

_ROOT = '/home/junjie/01_Research/SGLATrack-main'
_S3PY = '/home/junjie/01_Research/SGLATrack-main/s3lab_research_v1/python'
_DATA = f'{_ROOT}/data'


def local_env_settings():
    settings = EnvSettings()

    # ViT 測試；prj_dir 須為本 tree 根目錄（內含 experiments/sglatrack/*.yaml）。
    settings.davis_dir = ''
    settings.dtb70_path = f'{_DATA}/dtb70/DTB70'
    settings.got10k_lmdb_path = f'{_DATA}/got10k_lmdb'
    settings.got10k_path = f'{_DATA}/got10k'
    settings.got_packed_results_path = ''
    settings.got_reports_path = ''
    settings.itb_path = f'{_DATA}/itb'
    settings.lasot_extension_subset_path_path = f'{_DATA}/lasot_extension_subset'
    settings.lasot_lmdb_path = f'{_DATA}/lasot_lmdb'
    settings.lasot_path = f'{_DATA}/lasot'
    settings.network_path = f'{_S3PY}/output_vit/test/networks'
    settings.nfs_path = f'{_DATA}/nfs'
    settings.otb_path = f'{_DATA}/otb'
    settings.prj_dir = _S3PY
    settings.result_plot_path = f'{_S3PY}/output_vit/test/result_plots'
    settings.results_path = f'{_S3PY}/output_vit/test/tracking_results'
    settings.save_dir = f'{_S3PY}/output_vit'
    settings.segmentation_path = f'{_S3PY}/output_vit/test/segmentation_results'
    settings.tc128_path = f'{_DATA}/TC128'
    settings.tn_packed_results_path = ''
    settings.tnl2k_path = f'{_DATA}/tnl2k'
    settings.tpl_path = ''
    settings.trackingnet_path = f'{_DATA}/trackingnet'
    settings.uav123_10fps_path = f'{_DATA}/uav123_10fps/UAV123_10fps'
    settings.uav123_path = f'{_DATA}/uav123/UAV123'
    settings.uav_path = f'{_DATA}/uav'
    settings.uavdt_path = f'{_DATA}/uavdt/home/data/uavdt'
    settings.uavtrack_path = f'{_DATA}/uavtrack112/home/data/V4RFlight112'
    settings.visdrone_path = f'{_DATA}/visdrone/VisDrone2018-SOT-test-dev'
    settings.vot18_path = f'{_DATA}/vot2018'
    settings.vot22_path = f'{_DATA}/vot2022'
    settings.vot_path = f'{_DATA}/VOT2019'
    settings.youtubevos_dir = ''

    return settings
