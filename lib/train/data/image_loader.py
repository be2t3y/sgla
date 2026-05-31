"""
Image loaders for training. Supports jpeg4py (faster) with OpenCV fallback.
"""
try:
    import jpeg4py
    JPEG4PY_AVAILABLE = True
except ImportError:
    JPEG4PY_AVAILABLE = False
    jpeg4py = None

import cv2
import numpy as np


def opencv_loader(path):
    """Load image using OpenCV (BGR, then convert to RGB)."""
    img = cv2.imread(path)
    if img is None:
        raise IOError(f"Could not load image: {path}")
    return cv2.cvtColor(img, cv2.COLOR_BGR2RGB)


def jpeg4py_loader(path):
    """Load image using jpeg4py (faster for JPEG)."""
    if not JPEG4PY_AVAILABLE:
        return opencv_loader(path)
    img = jpeg4py.JPEG(path).decode()
    if img is None:
        raise IOError(f"Could not load image: {path}")
    return img


def jpeg4py_loader_w_failsafe(path):
    """Try jpeg4py first, fallback to OpenCV on failure or if jpeg4py not installed."""
    if not JPEG4PY_AVAILABLE:
        return opencv_loader(path)
    try:
        img = jpeg4py.JPEG(path).decode()
        if img is None:
            return opencv_loader(path)
        return img
    except Exception:
        return opencv_loader(path)


def default_image_loader(path):
    """Use jpeg4py if available, else OpenCV."""
    return jpeg4py_loader_w_failsafe(path)


def imread_indexed(path):
    """Load indexed image (e.g. segmentation mask) preserving pixel values as object IDs."""
    img = cv2.imread(path, cv2.IMREAD_UNCHANGED)
    if img is None:
        raise IOError(f"Could not load image: {path}")
    return img
