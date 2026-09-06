import uuid
from uuid import UUID
from typing import Optional
from fastapi import UploadFile, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select

from app.models.user import User
from app.schemas.user_schema import UserCreate, UserUpdate
from app.core.security import hash_password, verify_password
from app.utils.cloudinary_upload import upload_image_to_cloudinary


class UserService:

    # -----------------------------------------
    # CREATE USER
    # -----------------------------------------
    @staticmethod
    async def create_user(db: AsyncSession, payload: UserCreate, file: Optional[UploadFile] = None):

        # Check duplicate phone
        result = await db.execute(select(User).where(User.phone == payload.phone))
        if result.scalar_one_or_none():
            raise HTTPException(status_code=400, detail="Phone number already registered")

        aadhar_url = None
        if file:
            contents = await file.read()
            aadhar_url = await upload_image_to_cloudinary(contents)

        user = User(
            id=uuid.uuid4(),
            full_name=payload.full_name,
            phone=payload.phone,
            email=payload.email,
            password_hash=hash_password(payload.password),
            role=payload.role,
            aadhar_image_url=aadhar_url
        )

        db.add(user)
        await db.commit()
        await db.refresh(user)
        return user

    # -----------------------------------------
    # LOGIN
    # -----------------------------------------
    @staticmethod
    async def authenticate_user(db: AsyncSession, phone: str, password: str):
        result = await db.execute(select(User).where(User.phone == phone))
        user = result.scalar_one_or_none()

        if not user:
            return None

        if not verify_password(password, user.password_hash):
            return None

        return user

    # -----------------------------------------
    # GET USER BY ID
    # -----------------------------------------
    @staticmethod
    async def get_user_by_id(db: AsyncSession, user_id: str):

        # Convert string → UUID
        try:
            user_uuid = UUID(user_id)
        except:
            return None

        result = await db.execute(select(User).where(User.id == user_uuid))
        return result.scalar_one_or_none()

    # -----------------------------------------
    # UPDATE USER
    # -----------------------------------------
    @staticmethod
    async def update_user(db: AsyncSession, user_id: str, data: UserUpdate, file: Optional[UploadFile] = None):

        user = await UserService.get_user_by_id(db, user_id)
        if not user:
            return None

        update_data = data.dict(exclude_unset=True)

        # Handle password
        if "password" in update_data:
            update_data["password_hash"] = hash_password(update_data.pop("password"))

        # Handle file upload
        if file:
            contents = await file.read()
            user.aadhar_image_url = await upload_image_to_cloudinary(contents)

        # Apply updates
        for key, value in update_data.items():
            setattr(user, key, value)

        await db.commit()
        await db.refresh(user)
        return user

    # -----------------------------------------
    # DELETE USER
    # -----------------------------------------
    @staticmethod
    async def delete_user(db: AsyncSession, user_id: str):
        user = await UserService.get_user_by_id(db, user_id)
        if not user:
            return False

        await db.delete(user)
        await db.commit()
        return True
    
    @staticmethod
    async def list_farmers(db: AsyncSession, skip: int = 0, limit: int = 100):
        stmt = (
            select(User)
            .where(User.role == "farmer")
            .offset(skip)
            .limit(limit)
        )

        result = await db.execute(stmt)
        return result.scalars().all()