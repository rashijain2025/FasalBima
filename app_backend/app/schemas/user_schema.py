from pydantic import BaseModel
from uuid import UUID
from typing import Optional
from typing import Literal, Optional
from datetime import datetime


# -------------------------
# CREATE USER
# -------------------------
class UserCreate(BaseModel):
    full_name: str
    phone: str
    password: str
    email: Optional[str] = None
    role: Literal["farmer", "admin"] = "farmer"


# -------------------------
# LOGIN
# -------------------------
class UserLogin(BaseModel):
    phone: str
    password: str


# -------------------------
# UPDATE USER
# -------------------------
class UserUpdate(BaseModel):
    full_name: Optional[str] = None
    phone: Optional[str] = None
    email: Optional[str] = None
    password: Optional[str] = None
    role: Optional[str] = None
    address: Optional[str] = None
    state: Optional[str] = None
    district: Optional[str] = None
    village: Optional[str] = None


# -------------------------
# RESPONSE MODEL
# -------------------------
class UserResponse(BaseModel):
    id: UUID
    full_name: str
    phone: str
    email: Optional[str] = None
    role: str
    is_verified: bool

    address: Optional[str] = None
    state: Optional[str] = None
    district: Optional[str] = None
    village: Optional[str] = None

    aadhar_number: Optional[str] = None
    aadhar_image_url: Optional[str] = None

    created_at: Optional[datetime] = None
    updated_at: Optional[datetime] = None

    class Config:
        from_attributes = True
        extra = "ignore"