import os

import cv2
import numpy as np
import torch
from torch import nn
from torch.nn.modules.transformer import _get_clones
from scipy.stats import multivariate_normal

from lib.models.layers.head import build_box_head
from lib.models.sglatrack.vit import vit_base_patch16_224
from lib.models.sglatrack.deit import deit_tiny_distilled_patch16_224, deit_tiny_t2t_distilled_patch16_224
from lib.utils.box_ops import box_xyxy_to_cxcywh


class sglatrack(nn.Module):

    def __init__(self, transformer, box_head, aux_loss=False, head_type="CORNER", feat_len_t=64,
                 orr_enable=False, orr_random_mask=False, orr_block_sz=16, orr_mask_ratio=0.3, orr_gaussian_sigma=64):
        """ Initializes the model.
        Parameters:
            transformer: torch module of the transformer architecture.
            aux_loss: True if auxiliary decoding losses (loss at each decoder layer) are to be used.
        """
        super().__init__()
        self.backbone = transformer
        self.box_head = box_head

        self.aux_loss = aux_loss
        self.head_type = head_type
        if head_type == "CORNER" or head_type == "CENTER":
            self.feat_sz_s = int(box_head.feat_sz)
            self.feat_len_s = int(box_head.feat_sz ** 2)

        self.feat_len_t = int(feat_len_t)
        self.orr_enable = bool(orr_enable)
        self.orr_random_mask = bool(orr_random_mask)
        self.orr_block_sz = int(orr_block_sz)
        self.orr_mask_ratio = float(orr_mask_ratio)
        self.orr_gaussian_sigma = float(orr_gaussian_sigma)
        self._orr_intensity = None

        self.is_distill_training = False

        if self.aux_loss:
            self.box_head = _get_clones(self.box_head, 6)

    def random_masking(self, n, h, w, d, mask_ratio, device):
        len_keep = int(h * w * (1 - mask_ratio))
        noise = torch.rand(n, h, w, device=device)
        noise_vec = torch.reshape(noise, (n, h * w))
        ids_shuffle = torch.argsort(noise_vec, dim=1)
        ids_restore = torch.argsort(ids_shuffle, dim=1)
        mask = torch.ones([n, h, w], device=device)
        mask_vec = torch.reshape(mask, (n, h * w))
        mask_vec[:, :len_keep] = 0
        mask_vec = torch.gather(mask_vec, dim=1, index=ids_restore)
        mask = torch.reshape(mask_vec, (n, h, w))
        return mask

    def simulate_inhomogeneous_poisson_process(self, intensity):
        num_points = np.random.poisson(intensity.max() * np.prod(intensity.shape), 1)[0]
        x_points = (np.floor(np.random.uniform(0, intensity.shape[1], num_points))).astype(np.int32)
        y_points = (np.floor(np.random.uniform(0, intensity.shape[0], num_points))).astype(np.int32)
        accept_prob = intensity[x_points, y_points] / intensity.max()
        accepted_points = np.random.rand(num_points) < accept_prob
        x_points = x_points[accepted_points]
        y_points = y_points[accepted_points]
        return x_points, y_points

    def random_masking_cox_process(self, intensity, n, h, w, mask_ratio, device):
        poisson_mean = int(h * w * mask_ratio)
        poisson_samples = np.random.poisson(poisson_mean, n)
        masks = []
        for i in range(n):
            inh_poisson_intensity = poisson_samples[i] * intensity
            x_points, y_points = self.simulate_inhomogeneous_poisson_process(inh_poisson_intensity)
            mask = torch.ones([1, h, w], device=device)
            mask[:, y_points, x_points] = 0
            masks.append(mask)
        return torch.cat(masks, dim=0)

    def masking_cox_process(self, n, intensity, block_sz, mask_ratio, device):
        h, w = intensity.shape
        hb = int(h / block_sz)
        wb = int(w / block_sz)
        assert h % block_sz == 0 and w % block_sz == 0, 'template size must be divisible by ORR_BLOCK_SZ'
        intensity = cv2.resize(intensity, dsize=(wb, hb))
        intensity = intensity / intensity.sum()
        mask = self.random_masking_cox_process(intensity, n, hb, wb, mask_ratio, device)
        mask = torch.nn.functional.interpolate(mask.unsqueeze(1), size=(h, w), mode='nearest')
        return mask

    def masking(self, template, block_sz, mask_ratio, device):
        n, d, h, w = template.shape
        hb = h // block_sz
        wb = w // block_sz
        assert h % block_sz == 0 and w % block_sz == 0, 'template size must be divisible by ORR_BLOCK_SZ'
        mask = self.random_masking(n, hb, wb, d, mask_ratio, device)
        mask = torch.nn.functional.interpolate(mask.unsqueeze(1), size=(h, w), mode='nearest')
        return mask

    def forward(self, template: torch.Tensor,
                search: torch.Tensor,
                ce_template_mask=None,
                ce_keep_rate=None,
                return_last_attn=False,
                is_distill=False,
                ):
        mask = None
        if (not is_distill) and self.training and self.orr_enable:
            if self.orr_random_mask:
                mask = self.masking(template, self.orr_block_sz, self.orr_mask_ratio, template.device)
                mask = mask.repeat(1, template.shape[1], 1, 1)
            else:
                if self._orr_intensity is None:
                    template_r = int(template.shape[-1] / 2)
                    sigma = self.orr_gaussian_sigma
                    gx, gy = np.mgrid[-template_r:template_r:1, -template_r:template_r:1]
                    pos = np.dstack((gx, gy))
                    intensity = multivariate_normal(
                        [0.0, 0.0],
                        [[sigma * template_r, 0.0], [0.0, sigma * template_r]],
                    ).pdf(pos)
                    intensity = intensity / intensity.sum()
                    self._orr_intensity = intensity
                intensity = self._orr_intensity
                mask = self.masking_cox_process(
                    template.shape[0], intensity, self.orr_block_sz, self.orr_mask_ratio, template.device
                )
                mask = mask.repeat(1, template.shape[1], 1, 1)

        x, aux_dict = self.backbone(z=template, x=search,
                                    ce_template_mask=ce_template_mask,
                                    ce_keep_rate=ce_keep_rate,
                                    return_last_attn=return_last_attn, )

        if self.training and (not is_distill) and mask is not None:
            x1, _ = self.backbone(z=template * mask, x=search,
                                  ce_template_mask=ce_template_mask,
                                  ce_keep_rate=ce_keep_rate,
                                  return_last_attn=return_last_attn, )
            sim_loss = torch.nn.functional.mse_loss(
                x[:, :self.feat_len_t], x1[:, :self.feat_len_t].detach()
            )
        else:
            sim_loss = torch.tensor(0.0, device=x.device)

        feat_last = x
        if isinstance(x, list):
            feat_last = x[-1]
        out = self.forward_head(feat_last, None)

        out.update(aux_dict)
        out['backbone_feat'] = x
        out['sim_loss'] = sim_loss
        return out

    def forward_test(self, template: torch.Tensor,
                search: torch.Tensor,
                ce_template_mask=None,
                ce_keep_rate=None,
                return_last_attn=False,
                ):
        x, aux_dict = self.backbone.forward_test(z=template, x=search )

        # Forward head
        feat_last = x
        if isinstance(x, list):
            feat_last = x[-1]
        out = self.forward_head(feat_last, None)

        out.update(aux_dict)
        out['backbone_feat'] = x
        return out


    def forward_head(self, cat_feature, gt_score_map=None):
        """
        cat_feature: output embeddings of the backbone, it can be (HW1+HW2, B, C) or (HW2, B, C)
        """
        enc_opt = cat_feature[:, -self.feat_len_s:] # encoder output for the search region (B, HW, C)
        opt = (enc_opt.unsqueeze(-1)).permute((0, 3, 2, 1)).contiguous()
        bs, Nq, C, HW = opt.size()
        opt_feat = opt.view(-1, C, self.feat_sz_s, self.feat_sz_s)

        if self.head_type == "CORNER":
            # run the corner head
            pred_box, score_map = self.box_head(opt_feat, True)
            outputs_coord = box_xyxy_to_cxcywh(pred_box)
            outputs_coord_new = outputs_coord.view(bs, Nq, 4)
            out = {'pred_boxes': outputs_coord_new,
            'score_map': score_map,
            }
            return out

        elif self.head_type == "CENTER":
            # run the center head
            score_map_ctr, bbox, size_map, offset_map = self.box_head(opt_feat, gt_score_map)
            outputs_coord = bbox
            outputs_coord_new = outputs_coord.view(bs, Nq, 4)
            out = {'pred_boxes': outputs_coord_new,
            'score_map': score_map_ctr,
            'size_map': size_map,
            'offset_map': offset_map}
            return out
        else:
            raise NotImplementedError


def build_sglatrack(cfg, training=True):
    current_dir = os.path.dirname(os.path.abspath(__file__))
    pretrained_path = os.path.join(current_dir, '../../../pretrained_models')

    if cfg.MODEL.PRETRAIN_FILE and ('sglatrack' not in cfg.MODEL.PRETRAIN_FILE) and training:
        pretrained = os.path.join(pretrained_path, cfg.MODEL.PRETRAIN_FILE)
    else:
        pretrained = ''

    if cfg.MODEL.BACKBONE.TYPE == 'vit_base_patch16_224':
        backbone = vit_base_patch16_224(pretrained, drop_path_rate=cfg.TRAIN.DROP_PATH_RATE)
        hidden_dim = backbone.embed_dim
        patch_start_index = 1
    elif cfg.MODEL.BACKBONE.TYPE in ('deit_tiny_distilled_patch16', 'deit_tiny_distilled_patch16_224'):
        backbone = deit_tiny_distilled_patch16_224(pretrained, drop_path_rate=cfg.TRAIN.DROP_PATH_RATE)
        hidden_dim = backbone.embed_dim
        patch_start_index = 2
    elif cfg.MODEL.BACKBONE.TYPE == 'deit_tiny_t2t_distilled_patch16':
        backbone = deit_tiny_t2t_distilled_patch16_224(pretrained, drop_path_rate=cfg.TRAIN.DROP_PATH_RATE)
        hidden_dim = backbone.embed_dim
        patch_start_index = 2
    else:
        raise NotImplementedError

    backbone.finetune_track(cfg=cfg, patch_start_index=patch_start_index)

    box_head = build_box_head(cfg, hidden_dim)

    tpl = int(cfg.DATA.TEMPLATE.SIZE)
    stride = int(cfg.MODEL.BACKBONE.STRIDE)
    feat_len_t = (tpl // stride) ** 2

    model = sglatrack(
        backbone,
        box_head,
        aux_loss=False,
        head_type=cfg.MODEL.HEAD.TYPE,
        feat_len_t=feat_len_t,
        orr_enable=getattr(cfg.MODEL, "ORR_ENABLE", False),
        orr_random_mask=getattr(cfg.MODEL, "ORR_RANDOM_MASK", False),
        orr_block_sz=int(getattr(cfg.MODEL, "ORR_BLOCK_SZ", 16)),
        orr_mask_ratio=float(getattr(cfg.MODEL, "ORR_MASK_RATIO", 0.3)),
        orr_gaussian_sigma=float(getattr(cfg.MODEL, "ORR_GAUSSIAN_SIGMA", 64)),
    )

    _pf = str(cfg.MODEL.PRETRAIN_FILE or '')
    _load_track_ckpt = training and _pf and (
        'sglatrack' in _pf or _pf.endswith('.pth.tar') or _pf.endswith('.pth') or os.path.isfile(_pf)
    )
    if _load_track_ckpt:
        checkpoint = torch.load(cfg.MODEL.PRETRAIN_FILE, map_location="cpu")
        checkpoint_model = checkpoint["net"]

        # Handle position embedding size mismatch
        if 'backbone.pos_embed_x' in checkpoint_model:
            pos_embed_checkpoint = checkpoint_model['backbone.pos_embed_x']
            pos_embed_model = model.backbone.pos_embed_x

            if pos_embed_checkpoint.shape != pos_embed_model.shape:
                print(f'Position embedding size mismatch for pos_embed_x:')
                print(f'  Checkpoint: {pos_embed_checkpoint.shape}')
                print(f'  Model: {pos_embed_model.shape}')
                print(f'  Resizing position embedding...')

                pos_embed_checkpoint = pos_embed_checkpoint.permute(0, 2, 1)
                old_size = int(pos_embed_checkpoint.shape[2] ** 0.5)
                new_size = int(pos_embed_model.shape[1] ** 0.5)
                pos_embed_checkpoint = pos_embed_checkpoint.reshape(1, pos_embed_checkpoint.shape[1], old_size, old_size)
                pos_embed_checkpoint = torch.nn.functional.interpolate(
                    pos_embed_checkpoint, size=(new_size, new_size), mode='bicubic', align_corners=False
                )
                pos_embed_checkpoint = pos_embed_checkpoint.reshape(1, pos_embed_checkpoint.shape[1], -1).permute(0, 2, 1)
                checkpoint_model['backbone.pos_embed_x'] = pos_embed_checkpoint
                print(f'  Resized to: {pos_embed_checkpoint.shape}')

        if 'backbone.pos_embed_z' in checkpoint_model:
            pos_embed_checkpoint = checkpoint_model['backbone.pos_embed_z']
            pos_embed_model = model.backbone.pos_embed_z

            if pos_embed_checkpoint.shape != pos_embed_model.shape:
                print(f'Position embedding size mismatch for pos_embed_z:')
                pos_embed_checkpoint = pos_embed_checkpoint.permute(0, 2, 1)
                old_size = int(pos_embed_checkpoint.shape[2] ** 0.5)
                new_size = int(pos_embed_model.shape[1] ** 0.5)
                pos_embed_checkpoint = pos_embed_checkpoint.reshape(1, pos_embed_checkpoint.shape[1], old_size, old_size)
                pos_embed_checkpoint = torch.nn.functional.interpolate(
                    pos_embed_checkpoint, size=(new_size, new_size), mode='bicubic', align_corners=False
                )
                pos_embed_checkpoint = pos_embed_checkpoint.reshape(1, pos_embed_checkpoint.shape[1], -1).permute(0, 2, 1)
                checkpoint_model['backbone.pos_embed_z'] = pos_embed_checkpoint

        # Remove MLP weights if size mismatch
        mlp_keys_to_remove = []
        for key in list(checkpoint_model.keys()):
            if 'MLP' in key:
                checkpoint_weight = checkpoint_model[key]
                if hasattr(model, 'backbone') and hasattr(model.backbone, 'MLP'):
                    model_key = key.replace('backbone.', '')
                    try:
                        model_weight = dict(model.backbone.named_parameters())[model_key]
                        if checkpoint_weight.shape != model_weight.shape:
                            mlp_keys_to_remove.append(key)
                    except KeyError:
                        pass

        for key in mlp_keys_to_remove:
            del checkpoint_model[key]

        if mlp_keys_to_remove:
            print(f'Removed {len(mlp_keys_to_remove)} MLP weights from checkpoint due to size mismatch')

        missing_keys, unexpected_keys = model.load_state_dict(checkpoint_model, strict=False)
        print('Load pretrained model from: ' + cfg.MODEL.PRETRAIN_FILE)

    return model
