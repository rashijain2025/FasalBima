import numpy as np
from utils.preprocessing import load_and_preprocess

STAGE_LABELS = ["sowing", "vegetative", "flowering", "maturity"]

class CropStageService:

    def extract_features(self, img):
        """
        Rule-based logic using raw numpy pixels.
        """

        # img is already a NumPy array
        # % green pixels (vegetative indicator)
        green_mask = (img[:, :, 1] > 120) & (img[:, :, 0] < 130)
        green_ratio = green_mask.mean()

        # % yellow pixels (flowering/maturity indicator)
        yellow_mask = (img[:, :, 0] > 160) & (img[:, :, 1] > 140)
        yellow_ratio = yellow_mask.mean()

        # Overall brightness
        brightness = img.mean()

        return green_ratio, yellow_ratio, brightness

    def predict(self, image_bytes):
        # We only need the RAW NUMPY IMAGE
        _, _, raw_img = load_and_preprocess(image_bytes, return_raw=True)

        # Extract pixel-based features
        g, y, b = self.extract_features(raw_img)

        # RULE LOGIC
        if b < 70:
            return "sowing", 0.88

        if g > 0.40:
            return "vegetative", float(g)

        if y > 0.25:
            return "flowering", float(y)

        return "maturity", 0.72
