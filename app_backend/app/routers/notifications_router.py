from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select

from app.core.database import get_db
from app.schemas.notification_schema import NotificationSendRequest
from app.models.notification import Notification
from app.models.scheduler_model import Scheduler
from app.services.notification_service import NotificationService

router = APIRouter(tags=["Notifications / Scheduler"])


# -------------------------
# SEND NOTIFICATION
# -------------------------
@router.post("/send")
async def send_notification(
    payload: NotificationSendRequest,
    db: AsyncSession = Depends(get_db),
):
    result = await NotificationService.send_and_store(
        db=db,
        user_id=payload.user_id,
        token=payload.fcm_token,
        title=payload.title,
        message=payload.message,
        type=payload.type,
        notification_date=payload.notification_date,
    )
    return {"status": "sent", "data": result}


# -------------------------
# FETCH ALL NOTIFICATIONS FOR A FARMER
# -------------------------
@router.get("/farmer/{farmer_id}")
async def get_notifications_for_farmer(
    farmer_id: str,
    db: AsyncSession = Depends(get_db)
):
    res = await db.execute(
        select(Notification)
        .where(Notification.user_id == farmer_id)
        .order_by(Notification.created_at.desc())
    )

    return res.scalars().all()


# -------------------------
# MARK AS READ
# -------------------------
@router.put("/{notif_id}/read")
async def mark_as_read(notif_id: str, db: AsyncSession = Depends(get_db)):

    res = await db.execute(
        select(Notification).where(Notification.id == notif_id)
    )
    notif = res.scalar_one_or_none()

    if not notif:
        raise HTTPException(status_code=404, detail="Notification not found")

    notif.is_read = True
    await db.commit()

    return {"status": "read"}


# -------------------------
# GET SCHEDULED TASKS FOR FARMER
# -------------------------
@router.get("/schedules/{farmer_id}")
async def get_scheduled_image_tasks(farmer_id: str, db: AsyncSession = Depends(get_db)):

    res = await db.execute(
        select(Scheduler)
        .where(Scheduler.farmer_id == farmer_id)
        .order_by(Scheduler.scheduled_for.asc())
    )

    return res.scalars().all()
