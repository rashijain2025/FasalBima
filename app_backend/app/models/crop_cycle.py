import uuid
from datetime import datetime

from sqlalchemy import (
    Column, String, ForeignKey, Date, DateTime, JSON, Boolean, Float
)
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func

from app.core.database import Base


class CropCycle(Base):
    __tablename__ = "crop_cycles"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    plot_id = Column(UUID(as_uuid=True), ForeignKey("plots.id", ondelete="CASCADE"), nullable=False)

    crop_type = Column(String, nullable=False)
    season = Column(String, nullable=True)
    variety = Column(String, nullable=True)
    sowing_date = Column(Date, nullable=True)
    expected_harvest_date = Column(Date, nullable=True)

    current_stage = Column(String, nullable=True, default="sowing")
    is_active = Column(Boolean, default=True, nullable=False)

    latest_image_url = Column(String, nullable=True)
    latest_ml_prediction = Column(JSON, nullable=True)
    next_capture_date = Column(Date, nullable=True)

    created_at = Column(DateTime(timezone=True), server_default=func.now(), nullable=False)
    updated_at = Column(DateTime(timezone=True), onupdate=func.now())

    plot = relationship("Plot", back_populates="crop_cycles")
    images = relationship("CropImageHistory", back_populates="crop_cycle", cascade="all, delete-orphan")
    claims = relationship("Claim", back_populates="crop_cycle", cascade="all, delete-orphan")


