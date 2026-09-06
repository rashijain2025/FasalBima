# models/claim_model.py
import uuid
from sqlalchemy import Column, String, ForeignKey, DateTime, Numeric, JSON
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
from app.core.database import Base

class Claim(Base):
    __tablename__ = "claims"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)

    farmer_id = Column(UUID(as_uuid=True), ForeignKey("users.id"), nullable=False)
    plot_id = Column(UUID(as_uuid=True), ForeignKey("plots.id"), nullable=False)
    crop_cycle_id = Column(UUID(as_uuid=True), ForeignKey("crop_cycles.id"), nullable=True)

    # CLAIM DETAILS (required by your API)
    claim_reason = Column(String, nullable=False)
    estimated_loss_amount = Column(Numeric(12, 2), nullable=False)
    description = Column(String, nullable=True)

    # Optional ML damage assessment
    ml_damage_assessment = Column(JSON, nullable=True)

    # Status workflow
    status = Column(String, nullable=False, default="pending")
    admin_notes = Column(String, nullable=True)

    created_at = Column(DateTime(timezone=True), server_default=func.now(), nullable=False)
    updated_at = Column(DateTime(timezone=True), onupdate=func.now())

    farmer = relationship("User", back_populates="claims")
    plot = relationship("Plot", back_populates="claims")
    crop_cycle = relationship("CropCycle", back_populates="claims")
    evidences = relationship("ClaimEvidence", back_populates="claim", cascade="all, delete-orphan")

    @property
    def farmer_name(self):
        return self.farmer.full_name if self.farmer else None

    @property
    def crop_type(self):
        return self.crop_cycle.crop_type if self.crop_cycle else None

    @property
    def village(self):
        if self.plot and self.plot.village:
            return self.plot.village
        return self.farmer.village if self.farmer else None

    @property
    def district(self):
        if self.plot and self.plot.district:
            return self.plot.district
        return self.farmer.district if self.farmer else None

    @property
    def lat(self):
        if self.plot and self.plot.boundary_coordinates:
            try:
                coords = self.plot.boundary_coordinates
                if isinstance(coords, list) and len(coords) > 0:
                    return coords[0].get("lat", coords[0].get("latitude"))
            except Exception:
                pass
        return None

    @property
    def lng(self):
        if self.plot and self.plot.boundary_coordinates:
            try:
                coords = self.plot.boundary_coordinates
                if isinstance(coords, list) and len(coords) > 0:
                    return coords[0].get("lng", coords[0].get("longitude"))
            except Exception:
                pass
        return None


class ClaimEvidence(Base):
    __tablename__ = "claim_evidences"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    claim_id = Column(UUID(as_uuid=True), ForeignKey("claims.id"), nullable=False)

    evidence_type = Column(String, nullable=False)  # "image" or "document"
    url = Column(String, nullable=False)  # <-- replace file_url

    uploaded_at = Column(DateTime(timezone=True), server_default=func.now(), nullable=False)

    claim = relationship("Claim", back_populates="evidences")
