from fastapi import APIRouter, Depends, HTTPException
from fastapi.security import OAuth2PasswordRequestForm
from sqlalchemy.ext.asyncio import AsyncSession

from app.schemas.user_schema import UserCreate, UserLogin, UserResponse
from app.services.user_service import UserService
from app.core.database import get_db
from app.core.security import create_access_token
from app.core.oauth import get_current_user


router = APIRouter(tags=["Authentication"])


@router.post("/register", response_model=UserResponse)
async def register_user(payload: UserCreate, db: AsyncSession = Depends(get_db)):
    user = await UserService.create_user(db, payload)
    return user


@router.post("/login")
async def login(payload: UserLogin, db: AsyncSession = Depends(get_db)):
    user = await UserService.authenticate_user(db, payload.phone, payload.password)

    if not user:
        raise HTTPException(status_code=401, detail="Invalid credentials")

    # ONLY pass user_id as string
    token = create_access_token(str(user.id))

    return {
        "access_token": token,
        "token_type": "bearer"
    }

@router.post("/swagger-login", include_in_schema=False)
async def swagger_login(payload: OAuth2PasswordRequestForm = Depends(), db: AsyncSession = Depends(get_db)):
    # Swagger sends 'username', which we use as 'phone'
    user = await UserService.authenticate_user(db, payload.username, payload.password)
    
    if not user:
        raise HTTPException(status_code=401, detail="Invalid credentials")
        
    token = create_access_token(str(user.id))
    return {
        "access_token": token,
        "token_type": "bearer"
    }



@router.get("/me", response_model=UserResponse)
async def get_me(current_user=Depends(get_current_user)):
    return current_user
