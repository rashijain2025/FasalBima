# models/scheduler_model.py
import uuid
from sqlalchemy import Column, DateTime, Boolean, ForeignKey
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.sql import func

from app.core.database import Base

class Scheduler(Base):
    __tablename__ = "schedulers"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    farmer_id = Column(UUID(as_uuid=True), ForeignKey("users.id"), nullable=False)
    crop_cycle_id = Column(UUID(as_uuid=True), ForeignKey("crop_cycles.id"), nullable=False)

    scheduled_for = Column(DateTime(timezone=True), nullable=False)
    sent = Column(Boolean, default=False)

    created_at = Column(DateTime(timezone=True), server_default=func.now())
