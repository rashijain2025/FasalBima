from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

# DB
from app.core.database import Base, engine

# Import ALL models so SQLAlchemy registers them
from app.models import (
    user,
    plot,
    claim,
    crop_cycle,
    crop_image_history,
    ai_inference,
    notification,
    plot_document,
    enums,
    scheduler_model
)

# Routers
from app.routers.user_router import router as user_router
from app.routers.auth_router import router as auth_router
from app.routers.crop_router import router as crop_router
from app.routers.weather_router import router as weather_router
from app.routers.claim_router import router as claim_router
from app.routers.notifications_router import router as notifications_router
from app.routers.admin_router import router as admin_router
from app.routers.plot_router import router as plot_router


app = FastAPI(
    title="Fasal Bima Backend",
    description="API for farmer app with authentication, crops, weather, and more.",
    version="1.0.0"
)

# ----------------------------------------------------
# ASYNC TABLE CREATION FOR POSTGRESQL
# ----------------------------------------------------
async def init_models():
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)


@app.on_event("startup")
async def on_startup():
    await init_models()


# ----------------------------------------------------
# CORS
# ----------------------------------------------------
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Change later for production
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# ----------------------------------------------------
# ROUTERS
# ----------------------------------------------------
app.include_router(user_router, prefix="/api/users", tags=["Users"])
app.include_router(auth_router, prefix="/api/auth", tags=["Auth"])
app.include_router(crop_router, prefix="/api/crops", tags=["Crops"])
app.include_router(weather_router, prefix="/api/weather", tags=["Weather"])
app.include_router(notifications_router, prefix="/api/notifications", tags=["Notifications"])
app.include_router(claim_router, prefix="/api/claim", tags=["Claim"])
app.include_router(plot_router, prefix="/api/plots", tags=["Plots"])
app.include_router(admin_router, prefix="/api/admin", tags=["Admin"])
