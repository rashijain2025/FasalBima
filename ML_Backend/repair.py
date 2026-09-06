import tensorflow as tf
import os

# Path to your broken model
INPUT_MODEL = "models/quality.h5"

# Output repaired models
OUTPUT_SAVEDMODEL = "models/quality_fixed_savedmodel"
OUTPUT_H5 = "models/quality_fixed.h5"

print("🔧 Attempting to load broken H5 model...")

try:
    model = tf.keras.models.load_model(
        INPUT_MODEL,
        compile=False,
        safe_mode=False  # IMPORTANT FIX
    )
    print("✅ Model loaded successfully using safe_mode=False!")
except Exception as e:
    print("❌ FAILED TO LOAD MODEL!")
    print("Error:", str(e))
    raise SystemExit("Stopping repair process.")

print("\n🔧 Saving as SavedModel format...")
tf.saved_model.save(model, OUTPUT_SAVEDMODEL)
print("✅ SavedModel created successfully:", OUTPUT_SAVEDMODEL)

print("\n🔧 Reloading SavedModel (to normalize format)...")
model2 = tf.keras.models.load_model(OUTPUT_SAVEDMODEL, compile=False)

print("🔧 Exporting a CLEAN .h5 model...")
model2.save(OUTPUT_H5)
print("✅ New repaired H5 model saved at:", OUTPUT_H5)

print("\n🎉 Model repair completed!")
print("👉 Use this file in your FastAPI backend:")
print("models/quality_fixed.h5")
