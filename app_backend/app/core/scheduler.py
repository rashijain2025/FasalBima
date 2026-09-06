from apscheduler.schedulers.asyncio import AsyncIOScheduler
from sqlalchemy.ext.asyncio import AsyncSession
from app.database.db import get_db
from app.services.notification_service import NotificationService

scheduler = AsyncIOScheduler()

async def auto_image_capture_job():
    async for db in get_db():
        await NotificationService.process_scheduler_tasks(db)
        break

def start_scheduler():
    scheduler.add_job(auto_image_capture_job, "interval", hours=1)
    scheduler.start()
