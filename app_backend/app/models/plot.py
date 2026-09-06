import uuid
from sqlalchemy import (
    Column, String, ForeignKey, Boolean, DateTime,
    Float, JSON
)
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
from geoalchemy2 import Geometry

from app.core.database import Base


class Plot(Base):
    __tablename__ = "plots"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)

    # Farmer reference
    farmer_id = Column(UUID(as_uuid=True), ForeignKey("users.id", ondelete="CASCADE"), nullable=False)

    # Basic location info
    plot_name = Column(String, nullable=False)
    address = Column(String, nullable=False)
    village = Column(String, nullable=True)
    district = Column(String, nullable=True)
    state = Column(String, nullable=True)
    country = Column(String, nullable=True)

    # Area in hectares
    area_hectares = Column(Float, nullable=True)

    # Raw coordinates (list of lat/lng points)
    boundary_coordinates = Column(JSON, nullable=True)

    # Geometry: polygon + centroid (PostGIS)
    polygon = Column(Geometry("POLYGON", srid=4326), nullable=True)
    centroid = Column(Geometry("POINT", srid=4326), nullable=True)

    # Land verification documents
    land_document_url = Column(String, nullable=True)
    land_document_type = Column(String, nullable=True)  # e.g., "khasra", "title_deed"

    # Verification flags
    is_verified = Column(Boolean, default=False, nullable=False)
    verification_notes = Column(String, nullable=True)

    # Timestamps
    created_at = Column(DateTime(timezone=True), server_default=func.now(), nullable=False)
    updated_at = Column(DateTime(timezone=True), onupdate=func.now())

    # Relationships
    farmer = relationship("User", back_populates="plots")
    crop_cycles = relationship("CropCycle", back_populates="plot", cascade="all, delete-orphan")
    claims = relationship("Claim", back_populates="plot", cascade="all, delete-orphan")
