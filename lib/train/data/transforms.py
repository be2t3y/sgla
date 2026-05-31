import random
from typing import Any, Iterable, Tuple

import cv2 as cv
import numpy as np
import torch
import torchvision.transforms.functional as tvisf
from PIL import Image, ImageEnhance, ImageOps


def _to_tuple(x):
    if isinstance(x, tuple):
        return x
    return (x,)


class TransformBase:
    def roll(self):
        return ()

    def transform_image(self, image, *rand_params):
        return image

    def transform_bbox(self, bbox, image_shape, *rand_params):
        return bbox

    def transform_att(self, att, *rand_params):
        return att

    def transform_mask(self, mask, *rand_params):
        return mask


class Transform:
    def __init__(self, *transforms):
        self.transforms = transforms
        self._rand_params = None

    @staticmethod
    def _map_list(fn, data):
        if data is None:
            return None
        if isinstance(data, (list, tuple)):
            return [fn(x) for x in data]
        return fn(data)

    def __call__(self, image, bbox=None, att=None, mask=None, new_roll=True, joint=True):
        if new_roll or self._rand_params is None:
            self._rand_params = [(_to_tuple(t.roll())) for t in self.transforms]

        imgs = image
        boxes = bbox
        atts = att
        masks = mask

        for t, rand_params in zip(self.transforms, self._rand_params):
            imgs = self._map_list(lambda x: t.transform_image(x, *rand_params), imgs)
            if boxes is not None:
                boxes = self._map_list(
                    lambda b, _imgs=imgs: t.transform_bbox(
                        b,
                        _imgs[0].shape if isinstance(_imgs, list) else _imgs.shape,
                        *rand_params
                    ),
                    boxes
                )
            if atts is not None:
                atts = self._map_list(lambda a: t.transform_att(a, *rand_params), atts)
            if masks is not None:
                masks = self._map_list(lambda m: t.transform_mask(m, *rand_params), masks)

        outs = [imgs]
        if bbox is not None:
            outs.append(boxes)
        if att is not None:
            outs.append(atts)
        if mask is not None:
            outs.append(masks)
        return tuple(outs)


class ToTensor(TransformBase):
    def __init__(self, normalize=True):
        super().__init__()
        self.normalize = normalize

    def transform_image(self, image):
        image = np.ascontiguousarray(image)
        image = torch.from_numpy(image.transpose((2, 0, 1)))
        if self.normalize:
            return image.float().div(255.0)
        return image.float()

    def transform_att(self, att):
        if isinstance(att, np.ndarray):
            return torch.from_numpy(att).to(torch.bool)
        if isinstance(att, torch.Tensor):
            return att.to(torch.bool)
        return att

    def transform_mask(self, mask):
        if isinstance(mask, np.ndarray):
            return torch.from_numpy(mask)
        return mask


class ToTensorAndJitter(TransformBase):
    """Convert to Tensor and brightness jitter."""
    def __init__(self, brightness_jitter=0.0, normalize=True):
        super().__init__()
        self.brightness_jitter = brightness_jitter
        self.normalize = normalize

    def roll(self):
        return np.random.uniform(max(0, 1 - self.brightness_jitter), 1 + self.brightness_jitter)

    def transform_image(self, image, brightness_factor):
        image = np.ascontiguousarray(image)
        image = torch.from_numpy(image.transpose((2, 0, 1)))
        if self.normalize:
            return image.float().mul(brightness_factor / 255.0).clamp(0.0, 1.0)
        return image.float().mul(brightness_factor).clamp(0.0, 255.0)

    def transform_mask(self, mask, brightness_factor):
        if isinstance(mask, np.ndarray):
            return torch.from_numpy(mask)
        return mask

    def transform_att(self, att, brightness_factor):
        if isinstance(att, np.ndarray):
            return torch.from_numpy(att).to(torch.bool)
        if isinstance(att, torch.Tensor):
            return att.to(torch.bool)
        raise ValueError("dtype must be np.ndarray or torch.Tensor")


class Normalize(TransformBase):
    def __init__(self, mean, std, inplace=False):
        super().__init__()
        self.mean = mean
        self.std = std
        self.inplace = inplace

    def transform_image(self, image):
        return tvisf.normalize(image, self.mean, self.std, self.inplace)


class ToGrayscale(TransformBase):
    def __init__(self, probability=0.5):
        super().__init__()
        self.probability = probability

    def roll(self):
        return random.random() < self.probability

    def transform_image(self, image, do_grayscale):
        if do_grayscale:
            gr = cv.cvtColor(image, cv.COLOR_RGB2GRAY)
            return np.stack([gr, gr, gr], axis=2)
        return image


class RandomHorizontalFlip(TransformBase):
    def __init__(self, probability=0.5):
        super().__init__()
        self.probability = probability

    def roll(self):
        return random.random() < self.probability

    def transform_image(self, image, do_flip):
        if do_flip:
            return np.fliplr(image).copy()
        return image

    def transform_bbox(self, bbox, image_shape, do_flip):
        if not do_flip:
            return bbox
        out = bbox.clone() if torch.is_tensor(bbox) else np.copy(bbox)
        w = image_shape[1]
        out[0] = w - bbox[0] - bbox[2]
        return out

    def transform_att(self, att, do_flip):
        if do_flip:
            if isinstance(att, np.ndarray):
                return np.fliplr(att).copy()
            return torch.flip(att, dims=[1])
        return att

    def transform_mask(self, mask, do_flip):
        if do_flip:
            if isinstance(mask, np.ndarray):
                return np.fliplr(mask).copy()
            return torch.flip(mask, dims=[1])
        return mask


class RandomHorizontalFlip_Norm(TransformBase):
    """Horizontal flip for normalized bbox coords (x,y,w,h in [0,1])."""
    def __init__(self, probability=0.5):
        super().__init__()
        self.probability = probability

    def roll(self):
        return random.random() < self.probability

    def transform_image(self, image, do_flip):
        if not do_flip:
            return image
        if torch.is_tensor(image):
            return torch.flip(image, dims=[2])
        return np.fliplr(image).copy()

    def transform_bbox(self, bbox, image_shape, do_flip):
        if not do_flip:
            return bbox
        out = bbox.clone() if torch.is_tensor(bbox) else np.copy(bbox)
        out[0] = 1.0 - bbox[0] - bbox[2]
        return out

    def transform_att(self, att, do_flip):
        if do_flip:
            if isinstance(att, np.ndarray):
                return np.fliplr(att).copy()
            return torch.flip(att, dims=[1])
        return att

    def transform_mask(self, mask, do_flip):
        if do_flip:
            if isinstance(mask, np.ndarray):
                return np.fliplr(mask).copy()
            return torch.flip(mask, dims=[1])
        return mask


def _ra_color_autocontrast(pil_img):
    return ImageOps.autocontrast(pil_img)


def _ra_color_equalize(pil_img):
    return ImageOps.equalize(pil_img)


def _ra_color_posterize(pil_img, magnitude):
    bits = max(3, 8 - int(round(5 * magnitude / 10.0)))
    return ImageOps.posterize(pil_img, bits)


def _ra_color_solarize(pil_img, magnitude):
    thresh = int(256 - (256 * magnitude / 10.0))
    thresh = max(0, min(255, thresh))
    return ImageOps.solarize(pil_img, thresh)


def _ra_enhance(pil_img, enhancer_cls, magnitude, center=1.0, span=0.9):
    f = center + (magnitude / 10.0 - 0.5) * 2.0 * span
    f = max(0.1, min(1.9, f))
    return enhancer_cls(pil_img).enhance(f)


class RandAugmentColor(TransformBase):
    """Color-only RandAugment (no geometry)."""
    _OPS = None

    @classmethod
    def _get_ops(cls):
        if cls._OPS is not None:
            return cls._OPS
        cls._OPS = [
            lambda im, m: _ra_color_autocontrast(im),
            lambda im, m: _ra_color_equalize(im),
            lambda im, m: _ra_color_posterize(im, m),
            lambda im, m: _ra_color_solarize(im, m),
            lambda im, m: _ra_enhance(im, ImageEnhance.Color, m, center=1.0, span=0.5),
            lambda im, m: _ra_enhance(im, ImageEnhance.Contrast, m, center=1.0, span=0.5),
            lambda im, m: _ra_enhance(im, ImageEnhance.Brightness, m, center=1.0, span=0.4),
            lambda im, m: _ra_enhance(im, ImageEnhance.Sharpness, m, center=1.0, span=0.5),
        ]
        return cls._OPS

    def __init__(self, num_ops=2, magnitude=9, probability=0.7):
        super().__init__()
        self.num_ops = int(max(1, num_ops))
        self.magnitude = int(max(0, min(10, magnitude)))
        self.probability = float(max(0.0, min(1.0, probability)))

    def roll(self):
        return (random.random() < self.probability,)

    def transform_image(self, image, do_apply):
        if not do_apply:
            return image
        if torch.is_tensor(image):
            raise NotImplementedError("RandAugmentColor expects numpy RGB uint8 before ToTensor.")
        if image.dtype != np.uint8:
            image = np.clip(image, 0, 255).astype(np.uint8)
        pil = Image.fromarray(np.ascontiguousarray(image))
        ops = self._get_ops()
        for _ in range(self.num_ops):
            pil = random.choice(ops)(pil, self.magnitude)
        return np.asarray(pil).copy()

    def transform_mask(self, mask, do_apply):
        return mask

    def transform_att(self, att, do_apply):
        return att
