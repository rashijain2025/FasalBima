import uuid
from sqlalchemy import Column, String, ForeignKey, DateTime, JSON
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.sql import func
from sqlalchemy.orm import relationship

from app.core.database import Base


class AIInference(Base):
    __tablename__ = "ai_inferences"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)

    # reference to the crop image or claim snapshot
    crop_image_id = Column(UUID(as_uuid=True), ForeignKey("crop_image_history.id"), nullable=True)
    claim_id = Column(UUID(as_uuid=True), ForeignKey("claims.id"), nullable=True)

    model_name = Column(String, nullable=False)
    model_version = Column(String, nullable=True)
    inputs = Column(JSON, nullable=True)   # metadata about input (image_url, exif, etc)
    outputs = Column(JSON, nullable=True)  # model outputs
    confidence = Column(JSON, nullable=True)

    created_at = Column(DateTime(timezone=True), server_default=func.now(), nullable=False)

    crop_image = relationship("CropImageHistory", backref="ai_inferences")
    claim = relationship("Claim", backref="ai_inferences")
