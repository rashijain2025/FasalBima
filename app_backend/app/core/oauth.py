from fastapi import Depends, HTTPException
from fastapi.security import OAuth2PasswordBearer
import jwt  # PyJWT
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from uuid import UUID

from app.core.database import get_db
from app.models.user import User
from app.core.config import settings


oauth_scheme = OAuth2PasswordBearer(tokenUrl="/api/auth/swagger-login")


async def get_current_user(
    token: str = Depends(oauth_scheme),
    db: AsyncSession = Depends(get_db)
):
    """Extract user from JWT token."""

    credentials_exception = HTTPException(
        status_code=401,
        detail="Could not validate credentials",
    )

    try:
        payload = jwt.decode(
            token,
            settings.JWT_SECRET_KEY,
            algorithms=[settings.JWT_ALGORITHM]
        )

        user_id = payload.get("sub")
        if not user_id:
            raise credentials_exception

        # SAFE conversion (IMPORTANT FIX)
        user_uuid = UUID(str(user_id))

    except Exception:
        raise credentials_exception

    # Query database
    result = await db.execute(select(User).where(User.id == user_uuid))
    user = result.scalar_one_or_none()

    if not user:
        raise credentials_exception

    return user
