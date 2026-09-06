# app/schemas/claim_schema.py

from pydantic import BaseModel
from uuid import UUID
from typing import Optional, List
from datetime import datetime


# ------------------------------------------------------
# BASE SCHEMA (fields shared by create + response)
# ------------------------------------------------------
class ClaimBase(BaseModel):
    claim_reason: str
    estimated_loss_amount: float
    description: Optional[str] = None


# ------------------------------------------------------
# CREATE CLAIM
# ------------------------------------------------------
class ClaimCreate(BaseModel):
    claim_reason: str
    estimated_loss_amount: float
    description: Optional[str]
    crop_cycle_id: UUID
    image_urls: Optional[List[str]]


# ------------------------------------------------------
# UPDATE CLAIM (Farmer/Admin)
# ------------------------------------------------------
class ClaimUpdate(BaseModel):
    claim_reason: Optional[str] = None
    estimated_loss_amount: Optional[float] = None
    description: Optional[str] = None
    status: Optional[str] = None
    admin_notes: Optional[str] = None


# ------------------------------------------------------
# EVIDENCE SCHEMA
# ------------------------------------------------------
class ClaimEvidenceResponse(BaseModel):
    id: UUID
    claim_id: UUID
    url: str
    uploaded_at: datetime

    class Config:
        from_attributes = True


# ------------------------------------------------------
# RESPONSE MODEL (full claim data)
# ------------------------------------------------------
class ClaimResponse(BaseModel):
    id: UUID

    crop_cycle_id: Optional[UUID] = None
    farmer_id: Optional[UUID] = None

    claim_reason: Optional[str] = None
    estimated_loss_amount: Optional[float] = None
    description: Optional[str] = None

    status: Optional[str] = None
    admin_notes: Optional[str] = None

    image_urls: List[str] = []

    # name MUST match SQLAlchemy relationship "claim_evidences"
    evidences: List[ClaimEvidenceResponse] = []

    ml_damage_prediction: Optional[str] = None

    farmer_name: Optional[str] = None
    crop_type: Optional[str] = None
    village: Optional[str] = None
    district: Optional[str] = None
    lat: Optional[float] = None
    lng: Optional[float] = None

    created_at: Optional[datetime] = None
    updated_at: Optional[datetime] = None

    class Config:
        from_attributes = True
        extra = "ignore"



class ClaimAdminReview(BaseModel):
    approve: bool
    admin_notes: Optional[str] = None