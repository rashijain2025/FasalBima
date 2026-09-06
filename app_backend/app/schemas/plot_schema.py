from pydantic import BaseModel
from uuid import UUID
from typing import Optional, List
from datetime import datetime


class PlotBase(BaseModel):
    plot_name: str
    address: str
    village: Optional[str] = None
    district: Optional[str] = None
    state: Optional[str] = None
    country: Optional[str] = None
    area_hectares: Optional[float] = None

    # List of [lat, lon] pairs
    boundary_coordinates: Optional[List[List[float]]] = None

    land_document_url: Optional[str] = None
    land_document_type: Optional[str] = None


class PlotCreate(PlotBase):
    farmer_id: UUID
    polygon: Optional[str] = None   # stored as WKT
    centroid: Optional[str] = None  # optional


class PlotUpdate(BaseModel):
    plot_name: Optional[str] = None
    address: Optional[str] = None
    area_hectares: Optional[float] = None
    boundary_coordinates: Optional[List[List[float]]] = None
    land_document_url: Optional[str] = None
    land_document_type: Optional[str] = None


class PlotResponse(PlotBase):
    id: UUID
    farmer_id: UUID
    is_verified: bool
    verification_notes: Optional[str]
    created_at: datetime
    updated_at: Optional[datetime]

    class Config:
        from_attributes = True
