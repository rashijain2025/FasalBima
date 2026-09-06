import uuid
from sqlalchemy import Column, String, ForeignKey, DateTime
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func

from app.core.database import Base


class PlotDocument(Base):
    __tablename__ = "plot_documents"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    plot_id = Column(UUID(as_uuid=True), ForeignKey("plots.id", ondelete="CASCADE"), nullable=False)

    uploaded_by = Column(UUID(as_uuid=True), ForeignKey("users.id"), nullable=True)  # uploader user id
    doc_type = Column(String, nullable=True)  # e.g., "khasra", "tax_receipt"
    file_url = Column(String, nullable=False)  # Cloudinary URL or other storage url
    file_name = Column(String, nullable=True)

    created_at = Column(DateTime(timezone=True), server_default=func.now(), nullable=False)

    # Relationships
    plot = relationship("Plot", backref="documents")
