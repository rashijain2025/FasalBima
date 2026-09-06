from fastapi import APIRouter, Depends, UploadFile, File, HTTPException
from typing import List
from sqlalchemy.ext.asyncio import AsyncSession
from fastapi import APIRouter, UploadFile, File, Form, Depends, HTTPException

from app.core.database import get_db
from app.core.oauth import get_current_user

from app.schemas.crop_schema import (
    CropCycleCreate,
    CropCycleUpdate,
    CropCycleResponse,
    CropImageHistoryResponse
)

from app.services.crop_cycle_service import CropCycleService
from app.services.geo_service import GeoService
from app.models.user import User

router = APIRouter(tags=["Crop Cycles"])


# -------------------------------------------------------------
# CREATE
# -------------------------------------------------------------
@router.post("/", response_model=CropCycleResponse)
async def create_crop_cycle(
    payload: CropCycleCreate,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    return await CropCycleService.create_cycle(db, payload)


# -------------------------------------------------------------
# GET MY CYCLES
# -------------------------------------------------------------
@router.get("/me", response_model=List[CropCycleResponse])
async def get_my_crops(
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    return await CropCycleService.get_cycles_by_farmer(db, current_user.id)


# -------------------------------------------------------------
# GET SINGLE
# -------------------------------------------------------------
@router.get("/{cycle_id}", response_model=CropCycleResponse)
async def get_crop_cycle(
    cycle_id: str,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    cycle = await CropCycleService.get_cycle_by_id(db, cycle_id)
    if not cycle:
        raise HTTPException(404, "Cycle not found")

    if cycle.plot.farmer_id != current_user.id and current_user.role != "admin":
        raise HTTPException(403, "Not authorized")

    return cycle


# -------------------------------------------------------------
# UPDATE
# -------------------------------------------------------------
@router.put("/{cycle_id}", response_model=CropCycleResponse)
async def update_crop_cycle(
    cycle_id: str,
    payload: CropCycleUpdate,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    cycle = await CropCycleService.get_cycle_by_id(db, cycle_id)
    if not cycle:
        raise HTTPException(404, "Cycle not found")

    if cycle.plot.farmer_id != current_user.id and current_user.role != "admin":
        raise HTTPException(403, "Not authorized")

    return await CropCycleService.update_cycle(db, cycle_id, payload)


# -------------------------------------------------------------
# DELETE
# -------------------------------------------------------------
@router.delete("/{cycle_id}")
async def delete_crop_cycle(
    cycle_id: str,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    cycle = await CropCycleService.get_cycle_by_id(db, cycle_id)
    if not cycle:
        raise HTTPException(404, "Not found")

    if cycle.plot.farmer_id != current_user.id and current_user.role != "admin":
        raise HTTPException(403, "Not authorized")

    await CropCycleService.delete_cycle(db, cycle_id)
    return {"message": "Cycle deleted"}


# -------------------------------------------------------------
# UPLOAD IMAGE WITH ML + QUALITY CHECK + CLOUDINARY
# -------------------------------------------------------------
@router.post("/{cycle_id}/upload-image")
async def upload_crop_image(
    cycle_id: str,
    file: UploadFile = File(...),
    user_lat: float = Form(...),
    user_lng: float = Form(...),
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
):

    # 1️⃣ Validate crop cycle
    cycle = await CropCycleService.get_cycle_by_id(db, cycle_id)
    if not cycle:
        raise HTTPException(404, "Crop cycle not found")

    # 2️⃣ Read image
    image_bytes = await file.read()
    if not image_bytes:
        raise HTTPException(400, "Invalid or empty file")

    # 3️⃣ CALL ML BACKEND /predict
    from app.utils.ml_client import call_ml_service
    ml_result = await call_ml_service(
        image_bytes=image_bytes,
        lat=user_lat,
        lng=user_lng
    )
    print(ml_result)

    # If ML backend fails or returns error
    if not ml_result:
        raise HTTPException(500, "ML backend not responding")

    if ml_result.get("success") is False or "error" in ml_result:
        return ml_result

    # 4️⃣ Upload image to Cloudinary → because DB needs image_url
    from app.utils.cloudinary_upload import upload_media_to_cloudinary
    image_url = upload_media_to_cloudinary(image_bytes, file.content_type)

    # 5️⃣ Save crop image entry in DB
    saved_entry = await CropCycleService.store_crop_image(
        db=db,
        cycle=cycle,
        image_url=image_url,
        ml_result=ml_result,
        quality=ml_result.get("quality", "good"),
        lat=user_lat,
        lng=user_lng
    )
    

    # 6️⃣ Send notification
    from app.services.notification_service import NotificationService
    stress_label = ml_result.get("stress_class", "unknown")

    await NotificationService.send_crop_prediction_notification(
        db=db,
        user_id=current_user.id,
        prediction_label=stress_label
    )

    # 7️⃣ Return final result
    return {
        "success": True,
        "message": "Image processed via ML backend",
        "entry_id": saved_entry.id,
        "prediction": ml_result,
        "image_url": image_url
    }


# -------------------------------------------------------------
# IMAGE HISTORY
# -------------------------------------------------------------
@router.get("/{cycle_id}/images", response_model=List[CropImageHistoryResponse])
async def get_crop_images(
    cycle_id: str,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    cycle = await CropCycleService.get_cycle_by_id(db, cycle_id)
    if not cycle:
        raise HTTPException(404, "Not found")

    if cycle.plot.farmer_id != current_user.id and current_user.role != "admin":
        raise HTTPException(403, "Not authorized")

    return await CropCycleService.get_image_history(db, cycle_id)
