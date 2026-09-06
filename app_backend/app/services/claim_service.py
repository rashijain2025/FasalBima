import uuid
from datetime import datetime
from uuid import UUID

from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from sqlalchemy.orm import selectinload
from fastapi import HTTPException, UploadFile

from app.models.claim import Claim, ClaimEvidence
from app.models.crop_cycle import CropCycle
from app.models.notification import Notification
from app.schemas.claim_schema import ClaimCreate
from app.utils.cloudinary_upload import upload_media_to_cloudinary
from app.utils.notification_messages import claim_status_message


class ClaimService:

    # ---------------------------------------------------------
    # CREATE CLAIM
    # ---------------------------------------------------------
    @staticmethod
    async def create_claim(db: AsyncSession, farmer_id: str, payload: ClaimCreate, cycle: CropCycle):

        claim = Claim(
            id=uuid.uuid4(),
            crop_cycle_id=UUID(str(payload.crop_cycle_id)),
            plot_id=cycle.plot_id,
            farmer_id=UUID(str(farmer_id)),
            claim_reason=payload.claim_reason,
            estimated_loss_amount=payload.estimated_loss_amount,
            description=payload.description,
            status="pending",
            created_at=datetime.utcnow()
        )

        db.add(claim)
        await db.commit()
        await db.refresh(claim)

        # Save evidence URLs if provided
        if getattr(payload, "media_urls", None):
            for media in payload.media_urls:
                evidence = ClaimEvidence(
                    id=uuid.uuid4(),
                    claim_id=claim.id,
                    evidence_type=media.get("type"),
                    url=media.get("url"),
                    uploaded_at=datetime.utcnow()
                )
                db.add(evidence)

            await db.commit()

        await db.refresh(claim)
        return claim

    # ---------------------------------------------------------
    # ADD EVIDENCE
    # ---------------------------------------------------------
    @staticmethod
    async def add_evidence(db: AsyncSession, claim_id: str, file: UploadFile):

        claim = await ClaimService.get_claim_by_id(db, claim_id)
        if not claim:
            raise HTTPException(404, "Claim not found")

        file_bytes = await file.read()
        evidence_type = "video" if file.content_type.startswith("video") else "image"

        url = upload_media_to_cloudinary(file_bytes, file.content_type)

        evidence = ClaimEvidence(
            id=uuid.uuid4(),
            claim_id=claim.id,
            evidence_type=evidence_type,
            url=url,
            uploaded_at=datetime.utcnow()
        )

        db.add(evidence)
        await db.commit()
        await db.refresh(evidence)

        return evidence

    # ---------------------------------------------------------
    # GET CLAIM BY ID
    # ---------------------------------------------------------
    @staticmethod
    async def get_claim_by_id(db: AsyncSession, claim_id: str):
        try:
            uuid_val = UUID(str(claim_id))
        except:
            return None

        result = await db.execute(
            select(Claim)
            .where(Claim.id == uuid_val)
            .options(selectinload(Claim.evidences))
        )
        return result.scalar_one_or_none()

    # ---------------------------------------------------------
    # SET CLAIM STATUS + NOTIFICATION
    # ---------------------------------------------------------
    @staticmethod
    async def set_claim_status(
        db: AsyncSession,
        claim_id: str,
        status: str,
        admin_notes: str = None,
        admin_id: str = None,
    ):
        # Fetch claim
        result = await db.execute(
            select(Claim).where(Claim.id == UUID(str(claim_id)))
        )
        claim = result.scalars().first()

        if not claim:
            raise HTTPException(status_code=404, detail="Claim not found")

        # Update claim fields
        claim.status = status
        claim.admin_notes = admin_notes
        claim.reviewed_by = admin_id
        claim.reviewed_at = datetime.utcnow()

        await db.commit()
        await db.refresh(claim)

        # -------------------------------------------
        # 🔔 Send Notification
        # -------------------------------------------
        msg = claim_status_message(status, str(claim.id))

        notif = Notification(
            id=uuid.uuid4(),
            user_id=str(claim.farmer_id),
            title=msg["title"],
            message=msg["message"],
            notification_date=datetime.utcnow(),
            is_read=False
        )

        db.add(notif)
        await db.commit()
        await db.refresh(notif)

        return claim

    # ---------------------------------------------------------
    # LIST ALL CLAIMS (ADMIN)
    # ---------------------------------------------------------
    @staticmethod
    async def list_all_claims(
        db: AsyncSession,
        status: str | None = None,
        skip: int = 0,
        limit: int = 100,
    ):

        stmt = (
            select(Claim)
            .options(
                selectinload(Claim.evidences),
                selectinload(Claim.farmer),
                selectinload(Claim.plot),
                selectinload(Claim.crop_cycle)
            )
            .offset(skip)
            .limit(limit)
        )

        if status:
            stmt = stmt.where(Claim.status == status)

        result = await db.execute(stmt)
        return result.scalars().all()
