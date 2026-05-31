"""
Weights & Biases logger. Optional dependency - only required when use_wandb=1.
"""
try:
    import wandb
    WANDB_AVAILABLE = True
except ImportError:
    WANDB_AVAILABLE = False
    wandb = None


class WandbWriter:
    """Write training metrics to Weights & Biases."""

    def __init__(self, project_path, config_dict, log_dir, cur_train_samples, interval):
        if not WANDB_AVAILABLE:
            raise ImportError("Please run 'pip install wandb' to use wandb logging.")
        self.interval = interval
        wandb.init(project=project_path, config=config_dict, dir=log_dir, resume='allow')
        self.step = cur_train_samples

    def write_log(self, stats, epoch):
        if not WANDB_AVAILABLE:
            return
        log_dict = {}
        for loader_name, loader_stats in stats.items():
            if loader_stats is None:
                continue
            for var_name, val in loader_stats.items():
                if hasattr(val, 'history') and len(val.history) > 0:
                    log_dict[f"{loader_name}/{var_name}"] = val.history[-1]
        if log_dict:
            wandb.log(log_dict, step=self.step)
        self.step += self.interval
