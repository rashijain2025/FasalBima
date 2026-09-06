# import os
# import numpy as np
# import tensorflow as tf
# from utils.preprocessing import load_and_preprocess

# CROP_LABELS = ["Pepperbell", "cotton", "maize", "soybean", "sugarcane"]

# class CropTypeService:
#     def __init__(self):
#         # Build absolute path to .tflite
#         BASE_DIR = os.path.dirname(os.path.abspath(__file__))
#         model_path = os.path.join(BASE_DIR, "..", "models", "crop_type.tflite")
#         self.model_path = os.path.normpath(model_path)

#         print("Loading Crop Type TFLite model from:", self.model_path)

#         # Load TFLite model
#         self.interpreter = tf.lite.Interpreter(model_path=self.model_path)
#         self.interpreter.allocate_tensors()

#         # Get model input & output tensors
#         self.input_details = self.interpreter.get_input_details()
#         self.output_details = self.interpreter.get_output_details()

#     def predict(self, image_bytes):
#         # Preprocess the image → returns array in shape (1,224,224,3)
#         img = load_and_preprocess(image_bytes)

#         # Set input tensor
#         self.interpreter.set_tensor(self.input_details[0]['index'], img.astype(np.float32))

#         # Run inference
#         self.interpreter.invoke()

#         # Extract output tensor
#         output_data = self.interpreter.get_tensor(self.output_details[0]['index'])[0]

#         # Pick class with max probability
#         predicted_index = np.argmax(output_data)
#         return CROP_LABELS[predicted_index]
