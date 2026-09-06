import uuid
from datetime import datetime
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select

from app.models.notification import Notification
from app.models.user import User
from app.models.scheduler_model import Scheduler

from app.utils.notification_messages import generate_crop_prediction_message


class NotificationService:

    # --------------------------------------------------------------
    # BASE NOTIFICATION CREATOR (send + save) — TOKEN OPTIONAL
    # --------------------------------------------------------------
    @staticmethod
    async def send_and_store(
        db: AsyncSession,
        user_id: str,
        title: str,
        message: str,
        token: str = None,                 # OPTIONAL
        type: str = "system",              # DEFAULT
        notification_date: datetime = None # AUTO-FILL
    ):

        if notification_date is None:
            notification_date = datetime.utcnow()

        notif = Notification(
            id=uuid.uuid4(),
            user_id=user_id,
            title=title,
            message=message,
            notification_date=notification_date,
            is_read=False
        )

        db.add(notif)
        await db.commit()
        await db.refresh(notif)

        # (Optional) ADD FCM PUSH LOGIC HERE IF YOU WANT LATER

        return notif

    # --------------------------------------------------------------
    # CREATE NOTIFICATION FROM ML PREDICTION (MAIN NEW FUNCTION)
    # --------------------------------------------------------------
    @staticmethod
    async def send_crop_prediction_notification(
        db: AsyncSession,
        user_id: str,
        prediction_label: str
    ):
        """
        Uses prediction label to create an appropriate notification message.
        Calls send_and_store() internally.
        """

        # Generate message based on predicted label
        message = generate_crop_prediction_message(prediction_label)

        # Save into DB
        return await NotificationService.send_and_store(
            db=db,
            user_id=user_id,
            title="Crop Prediction Update",
            message=message,
            type="crop_prediction"
        )

    # --------------------------------------------------------------
    # PROCESS SCHEDULER IMAGE REMINDERS (ALREADY IN YOUR CODE)
    # --------------------------------------------------------------
    @staticmethod
    async def process_image_capture_scheduler(db: AsyncSession, farmer_id: str):

        result = await db.execute(
            select(Scheduler)
            .where(Scheduler.farmer_id == farmer_id)
            .where(Scheduler.completed == False)
        )
        tasks = result.scalars().all()

        notifications_sent = []

        for t in tasks:
            message = f"Image Capture Reminder: {t.stage_name} image is pending."

            notif = Notification(
                id=uuid.uuid4(),
                user_id=farmer_id,
                title="Image Capture Required",
                message=message,
                notification_date=datetime.utcnow(),
                is_read=False
            )

            db.add(notif)
            notifications_sent.append(message)

        await db.commit()

        return {
            "farmer_id": farmer_id,
            "total_notifications": len(notifications_sent),
            "messages": notifications_sent,
        }
