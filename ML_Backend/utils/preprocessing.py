import io
import numpy as np
from PIL import Image


def load_and_preprocess(image_bytes, return_raw=False):
    """
    Safely decode image bytes once and reuse PIL image everywhere.
    """

    if not image_bytes or len(image_bytes) < 20:
        raise ValueError(f"Invalid or empty image. Got {len(image_bytes)} bytes.")

    # 👉 Decode image ONCE
    try:
        pil_img = Image.open(io.BytesIO(image_bytes)).convert("RGB")
    except Exception as e:
        raise ValueError(f"Failed to decode image: {str(e)}")

    raw_np = np.array(pil_img)

    # 👉 Prepare ML input
    resized = pil_img.resize((224, 224))
    arr = np.array(resized).astype("float32") / 255.0
    arr = np.expand_dims(arr, axis=0)

    if return_raw:
        return pil_img, arr, raw_np

    return arr
import io
import numpy as np
import cv2
from PIL import Image

def load_image_bytes_as_cv2(image_bytes):
    """
    Converts raw file bytes into a CV2 BGR image.
    Used for quality model (blur, darkness, wrong image detection).
    """
    if image_bytes is None:
        raise ValueError("Image bytes cannot be None")

    # Decode using PIL first (more robust)
    try:
        pil_img = Image.open(io.BytesIO(image_bytes)).convert("RGB")
    except Exception as e:
        raise ValueError(f"Failed to decode image: {e}")

    # Convert PIL → numpy (RGB)
    img_np = np.array(pil_img)

    # Convert RGB → BGR for OpenCV
    img_bgr = cv2.cvtColor(img_np, cv2.COLOR_RGB2BGR)

    return img_bgr
