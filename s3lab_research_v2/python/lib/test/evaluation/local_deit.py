import os

from lib.test.evaluation.environment import EnvSettings


def _python_root():
    root = os.environ.get('SGLATRACK_PYTHON_ROOT', '').strip()
    if root:
        return os.path.abspath(root)
    # this file: python/lib/test/evaluation/local_deit.py
    return os.path.abspath(os.path.join(os.path.dirname(__file__), '..', '..', '..'))


def _data_dir():
    d = os.environ.get('SGLATRACK_DATA_DIR', '').strip()
    if d:
        return os.path.abspath(d)
    prj = _python_root()
    # 與 v1 local_*.py 一致：資料預設在 SGLATrack-main/data（python 上兩層目錄）
    repo_data = os.path.abspath(os.path.join(prj, '..', '..', 'data'))
    if os.path.isdir(repo_data):
        return repo_data
    return os.path.join(prj, 'data')


def local_env_settings():
    prj = _python_root()
    data = _data_dir()
    out = os.path.join(prj, 'output')
    settings = EnvSettings()

    settings.davis_dir = ''
    settings.dtb70_path = os.path.join(data, 'dtb70', 'DTB70')
    settings.got10k_lmdb_path = os.path.join(data, 'got10k_lmdb')
    settings.got10k_path = os.path.join(data, 'got10k')
    settings.got_packed_results_path = ''
    settings.got_reports_path = ''
    settings.itb_path = os.path.join(data, 'itb')
    settings.lasot_extension_subset_path_path = os.path.join(data, 'lasot_extension_subset')
    settings.lasot_lmdb_path = os.path.join(data, 'lasot_lmdb')
    settings.lasot_path = os.path.join(data, 'lasot')
    settings.network_path = os.path.join(out, 'test', 'networks')    # Where tracking networks are stored.
    settings.nfs_path = os.path.join(data, 'nfs')
    settings.otb_path = os.path.join(data, 'otb')
    settings.prj_dir = prj
    settings.result_plot_path = os.path.join(out, 'test', 'result_plots')
    settings.results_path = os.path.join(out, 'test', 'tracking_results')    # Where to store tracking results
    settings.save_dir = out
    settings.segmentation_path = os.path.join(out, 'test', 'segmentation_results')
    settings.tc128_path = os.path.join(data, 'TC128')
    settings.tn_packed_results_path = ''
    settings.tnl2k_path = os.path.join(data, 'tnl2k')
    settings.tpl_path = ''
    settings.trackingnet_path = os.path.join(data, 'trackingnet')
    settings.uav123_10fps_path = os.path.join(data, 'uav123_10fps', 'UAV123_10fps')
    settings.uav123_path = os.path.join(data, 'uav123', 'UAV123')
    settings.uav_path = os.path.join(data, 'uav')
    settings.uavdt_path = os.path.join(data, 'uavdt', 'home', 'data', 'uavdt')
    settings.uavtrack_path = os.path.join(data, 'uavtrack112', 'home', 'data', 'V4RFlight112')
    settings.visdrone_path = os.path.join(data, 'visdrone', 'VisDrone2018-SOT-test-dev')
    settings.vot18_path = os.path.join(data, 'vot2018')
    settings.vot22_path = os.path.join(data, 'vot2022')
    settings.vot_path = os.path.join(data, 'VOT2019')
    settings.youtubevos_dir = ''

    return settings
