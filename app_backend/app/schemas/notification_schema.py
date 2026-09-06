# schemas/notification_schema.py
from datetime import datetime
from typing import Optional
from uuid import UUID
from pydantic import BaseModel

# Base schema
class NotificationBase(BaseModel):
    title: str
    message: str
    notification_date: Optional[datetime] = None
    is_read: Optional[bool] = False

# Send request schema (rename for your router)
class NotificationSendRequest(NotificationBase):
    user_id: UUID
    fcm_token: str = None
    type: str = "general"

# Update schema
class NotificationUpdate(BaseModel):
    is_read: Optional[bool] = None

# Response schema
class NotificationResponse(NotificationBase):
    id: UUID
    user_id: UUID
    created_at: datetime

    class Config:
        orm_mode = True
