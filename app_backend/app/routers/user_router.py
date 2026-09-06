from fastapi import APIRouter, Depends, UploadFile, File, HTTPException
from typing import Optional
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.oauth import get_current_user
from app.core.database import get_db
from app.schemas.user_schema import UserResponse, UserUpdate
from app.services.user_service import UserService
from app.models.user import User


router = APIRouter(tags=["Users"])


# --------------------------------------------------------
# GET USER BY ID
# --------------------------------------------------------
@router.get("/{user_id}", response_model=UserResponse)
async def get_user(
    user_id: str,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    user = await UserService.get_user_by_id(db, user_id)
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    return user


# --------------------------------------------------------
# UPDATE USER
# --------------------------------------------------------
@router.put("/{user_id}", response_model=UserResponse)
async def update_user(
    user_id: str,
    payload: UserUpdate,  # <-- JSON comes here properly
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    if str(current_user.id) != str(user_id):
        raise HTTPException(status_code=403, detail="Cannot update another user's profile")

    updated_user = await UserService.update_user(db, user_id, payload)

    if not updated_user:
        raise HTTPException(status_code=404, detail="User not found")

    return updated_user

# --------------------------------------------------------
# DELETE USER
# --------------------------------------------------------
@router.delete("/{user_id}")
async def delete_user(
    user_id: str,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
):

    if str(current_user.id) != str(user_id):
        raise HTTPException(status_code=403, detail="Not allowed")

    deleted = await UserService.delete_user(db, user_id)
    if not deleted:
        raise HTTPException(status_code=404, detail="User not found")

    return {"message": "User deleted successfully"}
