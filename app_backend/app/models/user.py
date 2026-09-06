import uuid
from sqlalchemy import Column, String, Boolean, DateTime
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.sql import func
from sqlalchemy.orm import relationship

from app.core.database import Base


class User(Base):
    __tablename__ = "users"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)

    # Personal
    full_name = Column(String, nullable=False)
    phone = Column(String, unique=True, nullable=False, index=True)
    email = Column(String, nullable=True)

    # Identity verification
    aadhar_number = Column(String, nullable=True)
    aadhar_image_url = Column(String, nullable=True)  # Cloudinary URL
    is_verified = Column(Boolean, default=False, nullable=False)

    # Auth (store password hash)
    password_hash = Column(String, nullable=False)

    # Role
    role = Column(String, nullable=False, default="farmer")  # farmer / admin / inspector

    # Profile / address
    address = Column(String, nullable=True)
    state = Column(String, nullable=True)
    district = Column(String, nullable=True)
    village = Column(String, nullable=True)

    # Timestamps
    created_at = Column(DateTime(timezone=True), server_default=func.now(), nullable=False)
    updated_at = Column(DateTime(timezone=True), onupdate=func.now())

    # Relationships
    plots = relationship("Plot", back_populates="farmer", cascade="all, delete-orphan")
    claims = relationship("Claim", back_populates="farmer", cascade="all, delete-orphan")
