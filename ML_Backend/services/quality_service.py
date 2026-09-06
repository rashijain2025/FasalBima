import cv2
import numpy as np



QUALITY_LABELS = ["good", "blurry", "dark", "wrong"]

class QualityService:
    def __init__(self):
        print("Improved QualityService loaded (multi-rule system).")

    # -------------------------
    # DARKNESS CHECK
    # -------------------------
    def is_dark(self, gray):
        brightness = np.mean(gray)
        return brightness < 65, brightness

    # -------------------------
    # BLUR CHECK (Laplacian)
    # -------------------------
    def is_blurry(self, gray):
        sharpness = cv2.Laplacian(gray, cv2.CV_64F).var()
        return sharpness < 85, sharpness

    # -------------------------
    # SKY DETECTION (blue color)
    # -------------------------
    def detect_sky(self, img):
        hsv = cv2.cvtColor(img, cv2.COLOR_BGR2HSV)
        sky_mask = (
            (hsv[:, :, 0] > 90) & (hsv[:, :, 0] < 130) &
            (hsv[:, :, 2] > 120)
        )
        sky_ratio = sky_mask.mean()
        return sky_ratio > 0.30, sky_ratio  # >30% sky = not crop

    # -------------------------
    # VEGETATION INDEX (ExG)
    # -------------------------
    def vegetation_ratio(self, img):
        b, g, r = cv2.split(img)
        exg = 2*g - r - b  # Excess Green Index

        veg_mask = exg > 20
        veg_ratio = veg_mask.mean()

        return veg_ratio < 0.15, veg_ratio  # <15% veg → not crop

    # -------------------------
    # TEXTURE CHECK (plants have high texture)
    # -------------------------
    def texture_check(self, gray):
        edges = cv2.Canny(gray, 50, 150)
        edge_density = edges.mean()
        return edge_density < 0.02, edge_density

    # -------------------------
    # FINAL CLASSIFIER
    # -------------------------
    def classify(self, image_bytes):
        img_arr = np.frombuffer(image_bytes, np.uint8)
        img = cv2.imdecode(img_arr, cv2.IMREAD_COLOR)

        if img is None:
            print("[QUALITY] Cannot decode image.")
            return "wrong"

        gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)

        # ----------------------
        # 1: DARK CHECK
        # ----------------------
        dark, brightness = self.is_dark(gray)
        if dark:
            print(f"[QUALITY] DARK (brightness={brightness:.2f})")
            return "dark"

        # ----------------------
        # 2: BLUR CHECK
        # ----------------------
        blurry, sharpness = self.is_blurry(gray)
        if blurry:
            print(f"[QUALITY] BLURRY (sharpness={sharpness:.2f})")
            return "blurry"

        # ----------------------
        # 3: SKY CHECK
        # ----------------------
        sky, sky_ratio = self.detect_sky(img)
        if sky:
            print(f"[QUALITY] WRONG - too much sky (ratio={sky_ratio:.2f})")
            return "wrong"

        # ----------------------
        # 4: VEGETATION COVERAGE
        # ----------------------
        wrong_veg, veg_ratio = self.vegetation_ratio(img)
        if wrong_veg:
            print(f"[QUALITY] WRONG - low vegetation (veg_ratio={veg_ratio:.2f})")
            return "wrong"

        # ----------------------
        # 5: TEXTURE CHECK
        # ----------------------
        wrong_tex, tex_density = self.texture_check(gray)
        if wrong_tex:
            print(f"[QUALITY] WRONG - too smooth (edge_density={tex_density:.4f})")
            return "wrong"

        print("[QUALITY] GOOD IMAGE")
        return "good"

    def predict(self, img_bytes):
        return self.classify(img_bytes)
