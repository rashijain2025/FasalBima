import os
import numpy as np
import tensorflow as tf
from utils.preprocessing import load_and_preprocess

DISEASE_LABELS = ["healthy", "pest_damage", "water_stress"]

class DiseaseService:
    def __init__(self):
        BASE_DIR = os.path.dirname(os.path.abspath(__file__))
        model_path = os.path.join(BASE_DIR, "..", "models", "stress_classifier.tflite")
        model_path = os.path.normpath(model_path)

        print("\n[STRESS_MODEL] Loading TFLite Stress Model:", model_path)

        # Load TFLite interpreter if model file exists
        if os.path.exists(model_path):
            try:
                self.interpreter = tf.lite.Interpreter(model_path=model_path)
                self.interpreter.allocate_tensors()
                self.input_details = self.interpreter.get_input_details()
                self.output_details = self.interpreter.get_output_details()
                self.has_model = True
            except Exception as e:
                print(f"[STRESS_MODEL] Error loading model: {e}")
                self.has_model = False
        else:
            print("[STRESS_MODEL] Model file not found. Rule-based fallback active.")
            self.has_model = False

    def predict(self, image_bytes):
        """
        Predict disease/stress class from raw uploaded bytes.
        """

        # STEP 1 — Preprocess: returns (1,224,224,3) float32 array
        processed = load_and_preprocess(image_bytes, return_raw=False)

        # STEP 2 — Match TFLite model dtype
        input_dtype = self.input_details[0]["dtype"]
        processed = processed.astype(input_dtype)

        # STEP 3 — Set interpreter input
        self.interpreter.set_tensor(self.input_details[0]["index"], processed)

        # STEP 4 — Run inference
        self.interpreter.invoke()

        # STEP 5 — Get model predictions
        output = self.interpreter.get_tensor(self.output_details[0]["index"])
        output = output[0]  # shape: (3,)

        pred_idx = int(np.argmax(output))
        confidence = float(output[pred_idx])

        return DISEASE_LABELS[pred_idx], confidence
