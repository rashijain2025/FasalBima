# services/prediction_service.py
import random

class PredictionService:
    @staticmethod
    def run_prediction(image_url: str):
        """
        Dummy ML model. Replace with real local/remote model later.
        """
        stages = ["sowing", "vegetative", "flowering", "harvesting"]

        return {
            "stage": random.choice(stages),
            "prediction": "crop is healthy",
            "confidence": round(random.uniform(0.85, 0.99), 2)
        }
