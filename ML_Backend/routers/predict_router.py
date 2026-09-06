from fastapi import APIRouter, File, UploadFile, Form, HTTPException
from services.pipeline_service import PipelineService

router = APIRouter()
pipeline = PipelineService()

# 🔥 Hardcoded polygon
HARDCODED_POLYGON = [
    [23.4560, 76.5430],
    [23.4565, 76.5435],
    [23.4570, 76.5430]
]


@router.post("/predict")
async def predict(
    file: UploadFile = File(...),
    user_lat: float = Form(...),
    user_lng: float = Form(...)
):
    try:
        # -------------------- Read Image --------------------
        image_bytes = await file.read()

        if not image_bytes or len(image_bytes) == 0:
            raise HTTPException(
                status_code=400,
                detail="Uploaded file is empty or unreadable"
            )

        # -------------------- Use Hardcoded Polygon --------------------
        polygon = HARDCODED_POLYGON

        # -------------------- Run Pipeline --------------------
        try:
            result = pipeline.run_pipeline(
                image_bytes=image_bytes,
                user_lat=user_lat,
                user_lng=user_lng,
                polygon_coords=polygon
            )
        except Exception as e:
            raise HTTPException(
                status_code=500,
                detail=f"Pipeline processing failed: {str(e)}"
            )

        return result

    except HTTPException as e:
        raise e

    except Exception as e:
        return {
            "error": "Prediction Failed",
            "details": str(e)
        }
