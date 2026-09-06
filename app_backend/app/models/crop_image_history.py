# app/models/crop_image_history.py
from datetime import datetime
from sqlalchemy import Column, String, DateTime, Float, JSON, ForeignKey
from sqlalchemy.dialects.postgresql import UUID
import uuid
from sqlalchemy.orm import relationship
from app.core.database import Base

class CropImageHistory(Base):
    __tablename__ = "crop_image_history"
    __table_args__ = {"extend_existing": True}

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    crop_cycle_id = Column(UUID(as_uuid=True), ForeignKey("crop_cycles.id"), nullable=False)
    image_url = Column(String, nullable=False)
    latitude = Column(Float, nullable=True)
    longitude = Column(Float, nullable=True)
    ml_prediction = Column(JSON, nullable=True)

    # <-- add this (DB requires it)
    captured_at = Column(DateTime(timezone=True), default=datetime.utcnow, nullable=False)

    created_at = Column(DateTime(timezone=True), default=datetime.utcnow, nullable=False)

    crop_cycle = relationship("CropCycle", back_populates="images")
