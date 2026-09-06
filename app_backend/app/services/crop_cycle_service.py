import uuid
from datetime import datetime, timedelta, date
from uuid import UUID

from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, delete
from sqlalchemy.orm import selectinload

from fastapi import HTTPException, UploadFile

from app.models.crop_cycle import CropCycle
from app.models.crop_image_history import CropImageHistory
from app.models.plot import Plot
from app.schemas.crop_schema import CropCycleCreate, CropCycleUpdate

from app.utils.cloudinary_upload import upload_image_to_cloudinary
from app.services.notification_service import NotificationService


class CropCycleService:

    # ---------------------------------------------------------
    # CREATE CROP CYCLE
    # ---------------------------------------------------------
    @staticmethod
    async def create_cycle(db: AsyncSession, payload: CropCycleCreate):
        result = await db.execute(select(Plot).where(Plot.id == payload.plot_id))
        plot = result.scalar_one_or_none()

        if not plot:
            raise HTTPException(404, "Plot not found")

        next_capture = (
            payload.sowing_date + timedelta(days=10)
            if payload.sowing_date
            else date.today() + timedelta(days=10)
        )

        cycle = CropCycle(
            id=uuid.uuid4(),
            plot_id=payload.plot_id,
            crop_type=payload.crop_type,
            season=payload.season,
            variety=payload.variety,
            sowing_date=payload.sowing_date,
            expected_harvest_date=payload.expected_harvest_date,
            current_stage="sowing",
            is_active=True,
            latest_image_url=None,
            latest_ml_prediction=None,
            next_capture_date=next_capture,
        )

        db.add(cycle)
        await db.commit()
        await db.refresh(cycle)
        return cycle

    # ---------------------------------------------------------
    # GET ALL CYCLES OF A FARMER
    # ---------------------------------------------------------
    @staticmethod
    async def get_cycles_by_farmer(db: AsyncSession, farmer_id: UUID):
        result = await db.execute(
            select(CropCycle)
            .join(Plot, CropCycle.plot_id == Plot.id)
            .where(Plot.farmer_id == farmer_id)
            .options(selectinload(CropCycle.plot))
        )
        return result.scalars().all()

    # ---------------------------------------------------------
    # GET CYCLE BY ID
    # ---------------------------------------------------------
    @staticmethod
    async def get_cycle_by_id(db: AsyncSession, cycle_id):
        if isinstance(cycle_id, UUID):
            uuid_val = cycle_id
        else:
            try:
                uuid_val = UUID(str(cycle_id))
            except:
                return None

        result = await db.execute(
            select(CropCycle)
            .where(CropCycle.id == uuid_val)
            .options(selectinload(CropCycle.plot))
        )
        return result.scalar_one_or_none()

    # ---------------------------------------------------------
    # UPDATE
    # ---------------------------------------------------------
    @staticmethod
    async def update_cycle(db: AsyncSession, cycle_id: str, payload: CropCycleUpdate):
        cycle = await CropCycleService.get_cycle_by_id(db, cycle_id)
        if not cycle:
            return None

        update_data = payload.dict(exclude_unset=True)
        for key, value in update_data.items():
            setattr(cycle, key, value)

        await db.commit()
        await db.refresh(cycle)
        return cycle

    # ---------------------------------------------------------
    # DELETE
    # ---------------------------------------------------------
    @staticmethod
    async def delete_cycle(db: AsyncSession, cycle_id: str):
        try:
            uuid_val = UUID(cycle_id)
        except:
            return False

        await db.execute(delete(CropCycle).where(CropCycle.id == uuid_val))
        await db.commit()
        return True

    # ---------------------------------------------------------
    # IMAGE HISTORY
    # ---------------------------------------------------------
    @staticmethod
    async def get_image_history(db: AsyncSession, cycle_id: str):
        try:
            uuid_val = UUID(cycle_id)
        except:
            return []

        result = await db.execute(
            select(CropImageHistory)
            .where(CropImageHistory.crop_cycle_id == uuid_val)
            .order_by(CropImageHistory.timestamp.desc())
        )

        return result.scalars().all()

    # ---------------------------------------------------------
    # NEXT CAPTURE DATE LOGIC
    # ---------------------------------------------------------
    @staticmethod
    def _compute_next_capture(stage: str):
        stage_days = {
            "sowing": 5,
            "vegetative": 7,
            "flowering": 10,
            "maturity": 12,
            "harvesting": 15,
        }

        days = stage_days.get(stage.lower(), 7)
        return (datetime.utcnow() + timedelta(days=days)).date()

    # ---------------------------------------------------------
    # STAGE RESOLUTION LOGIC
    # ---------------------------------------------------------
    @staticmethod
    def _resolve_stage_transition(old_stage: str, new_stage: str):
        order = ["sowing", "vegetative", "flowering", "maturity", "harvesting"]

        old_idx = order.index(old_stage) if old_stage in order else 0
        new_idx = order.index(new_stage) if new_stage in order else old_idx

        return order[max(old_idx, new_idx)]

    # ---------------------------------------------------------
    # LIST ALL CYCLES (ADMIN)
    # ---------------------------------------------------------
    @staticmethod
    async def list_all_cycles(db: AsyncSession, skip: int = 0, limit: int = 100):
        stmt = select(CropCycle).offset(skip).limit(limit)
        result = await db.execute(stmt)
        return result.scalars().all()

    # ---------------------------------------------------------
    # NEW STORE IMAGE (FINAL VERSION WITH ML RESULT)
    # ---------------------------------------------------------
    @staticmethod
    async def store_crop_image(db: AsyncSession, cycle, image_url, ml_result, quality, lat, lng):

        new_entry = CropImageHistory(
            id=uuid.uuid4(),
            crop_cycle_id=cycle.id,
            image_url=image_url,
            latitude=lat,
            longitude=lng,
            ml_prediction=ml_result,
        
            created_at=datetime.utcnow(),
        )

        db.add(new_entry)
        await db.commit()
        await db.refresh(new_entry)

        return new_entry
