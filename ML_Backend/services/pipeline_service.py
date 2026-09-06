from services.quality_service import QualityService
from services.crop_stage_service import CropStageService
from services.disease_service import DiseaseService
from services.GEOLOCATION import GeoLocationService
from services.severity import SeverityService

from utils.preprocessing import load_and_preprocess
from utils.response_formatter import final_response, format_quality_response


class PipelineService:

    def __init__(self):
        print("\n================= PIPELINE INITIALIZED =================")
        self.geo = GeoLocationService()
        self.quality = QualityService()
        self.stage = CropStageService()
        self.disease = DiseaseService()
        self.severity = SeverityService()
        print("=======================================================\n")

    def run_pipeline(self, image_bytes, user_lat, user_lng, polygon_coords):

        print("\n================= PIPELINE START =================")
        print("[1] Image received. Bytes length:", len(image_bytes))
        print("[1] User Location:", user_lat, user_lng)
        print("[1] Polygon Coords:", polygon_coords)

        # STEP 1 — GEO-LOCATION CHECK
        try:
            inside = self.geo.is_inside_farm(user_lat, user_lng, polygon_coords)
            print("[2] GeoLocation Check:", inside)
        except Exception as e:
            print("[ERROR] GeoLocationService failed:", e)
            return {"error": "Geolocation service failed", "details": str(e)}

        if not inside:
            print("[STOP] User is OUTSIDE farm boundary\n")
            return {"error": "Please click the picture INSIDE your farm boundary."}

        # STEP 2 — QUALITY CHECK
        try:
            quality_label = self.quality.predict(image_bytes)
            print("[3] Quality Prediction:", quality_label)
        except Exception as e:
            print("[ERROR] QualityService failed:", e)
            return {"error": "Quality model failed", "details": str(e)}

        if quality_label != "good":
            print("[STOP] Poor image quality:", quality_label)
            return format_quality_response(quality_label)

        # STEP 3 — PREPROCESSING
        try:
            print("[4] Preprocessing image...")
            pil_img, processed_img, raw_img = load_and_preprocess(image_bytes, return_raw=True)
            print("[4] Preprocessing done — processed_img shape:", processed_img.shape)
            print("[4] Raw image shape:", raw_img.shape)
        except Exception as e:
            print("[ERROR] Preprocessing failed:", e)
            return {"error": "Image preprocessing failed", "details": str(e)}

        # STEP 4 — CROP STAGE
        try:
            stage_label, stage_conf = self.stage.predict(image_bytes)
            print(f"[5] Stage Prediction: {stage_label} ({stage_conf})")
        except Exception as e:
            print("[ERROR] CropStageService failed:", e)
            return {"error": "Stage prediction failed", "details": str(e)}

        # STEP 5 — DISEASE CLASSIFIER
        try:
            stress_label, stress_conf = self.disease.predict(image_bytes)
            print(f"[6] Disease Prediction: {stress_label} ({stress_conf})")
        except Exception as e:
            print("[ERROR] DiseaseService failed:", e)
            return {"error": "Disease prediction failed", "details": str(e)}

        # STEP 6 — SEVERITY ESTIMATION
        try:
            severity_score, severity_label = self.severity.compute(raw_img, stress_label)
            print(f"[7] Severity: {severity_score} ({severity_label})")
        except Exception as e:
            print("[ERROR] SeverityService failed:", e)
            return {"error": "Severity calculation failed", "details": str(e)}

        # STEP 7 — FINAL RESPONSE
        print("================= PIPELINE END =================\n")
        return final_response(
            quality="good",
            crop_type="Sugarcane",
            stage=stage_label,
            stage_confidence=round(float(stage_conf), 2),
            stress_class=stress_label,
            stress_confidence=round(float(stress_conf), 2),
            severity=severity_score,
            severity_label=severity_label
        )
