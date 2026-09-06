import numpy as np
import cv2

class SeverityService:

    def __init__(self):
        print("SeverityService loaded (improved rule-based).")

    def compute(self, raw_img, stress_class: str):
        """
        raw_img: numpy array (H,W,3)
        """

        if raw_img is None or raw_img.size == 0:
            return 0.0, "unknown"

        # Convert RGB → BGR for OpenCV
        img = cv2.cvtColor(raw_img, cv2.COLOR_RGB2BGR)

        h, w, _ = img.shape

        # HSV for color-based stress detection
        hsv = cv2.cvtColor(img, cv2.COLOR_BGR2HSV)
        H, S, V = hsv[:, :, 0], hsv[:, :, 1], hsv[:, :, 2]

        # NORMALIZATION HELPERS
        total_pixels = h * w
        eps = 1e-6

        # ======================================
        # 1️⃣ HEALTHY CASE
        # ======================================
        if stress_class == "healthy":
            return 0.05, "none"

        # ======================================
        # 2️⃣ PEST DAMAGE (dark brown / black spots)
        # ======================================
        if stress_class == "pest_damage":
            # Very strict filter now
            mask = (V < 90) & (S > 80)

            ratio = np.sum(mask) / total_pixels

            # smoother normalization
            severity = ratio * 1.8    # was 3.5 → too aggressive
            severity = np.clip(severity, 0, 1)

        # ======================================
        # 3️⃣ WATER STRESS (yellow patches)
        # ======================================
        elif stress_class == "water_stress":
            # more strict yellow detection
            mask = (H > 22) & (H < 32) & (S > 70) & (V > 120)

            ratio = np.sum(mask) / total_pixels

            severity = ratio * 1.4   # was 2.5 → too aggressive
            severity = np.clip(severity, 0, 1)

        else:
            return 0.0, "unknown"

        # ==============================
        # LABELING BASED ON SEVERITY
        # ==============================
        if severity < 0.15:
            label = "mild"
        elif severity < 0.45:
            label = "moderate"
        else:
            label = "severe"

        return round(float(severity), 3), label
