from pydantic import BaseModel
from typing import Optional, Any, Dict
from datetime import datetime, date
from uuid import UUID


# -------------------------
# CREATE DTO
# -------------------------
class CropCycleCreate(BaseModel):
    plot_id: UUID | str
    crop_type: str
    season: Optional[str] = None
    variety: Optional[str] = None
    sowing_date: Optional[date] = None
    expected_harvest_date: Optional[date] = None


# -------------------------
# UPDATE DTO
# -------------------------
class CropCycleUpdate(BaseModel):
    crop_type: Optional[str] = None
    season: Optional[str] = None
    variety: Optional[str] = None
    expected_harvest_date: Optional[date] = None


# -------------------------
# RESPONSE MODEL
# -------------------------
class CropCycleResponse(BaseModel):
    id: UUID
    plot_id: UUID
    crop_type: str
    season: Optional[str]
    variety: Optional[str]
    sowing_date: Optional[date]
    expected_harvest_date: Optional[date]

    current_stage: Optional[str]
    is_active: bool

    latest_image_url: Optional[str]
    latest_ml_prediction: Optional[Dict]     # <-- FIXED
    next_capture_date: Optional[date]

    created_at: Optional[datetime]
    updated_at: Optional[datetime]

    model_config = {
        "from_attributes": True,
        "arbitrary_types_allowed": True
    }


# -------------------------
# IMAGE HISTORY RESPONSE
# -------------------------
class CropImageHistoryResponse(BaseModel):
    id: str
    crop_cycle_id: str
    image_url: str
    captured_at: datetime
    latitude: Optional[float]
    longitude: Optional[float]
    device_model: Optional[str]
    exif: Optional[dict]
    ml_prediction: Optional[dict]
    ml_model_version: Optional[str]
    created_at: datetime

    class Config:
        from_attributes = True