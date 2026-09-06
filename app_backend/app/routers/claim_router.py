# app/routers/claim_router.py

from fastapi import (
    APIRouter,
    Depends,
    UploadFile,
    File,
    HTTPException,
    status
)
from typing import List, Optional
from app.schemas.claim_schema import ClaimAdminReview
from uuid import UUID
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.database import get_db
from app.core.oauth import get_current_user

from app.schemas.claim_schema import (
    ClaimCreate,
    ClaimResponse,
    ClaimUpdate
)

from app.services.claim_service import ClaimService
from app.services.crop_cycle_service import CropCycleService
from app.services.plot_service import PlotService
from app.models.user import User


router = APIRouter(
    tags=["Claims"]
)


# ---------------- CREATE CLAIM ----------------
@router.post("/", response_model=ClaimResponse, status_code=status.HTTP_201_CREATED)
async def create_claim(
    payload: ClaimCreate,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    cycle = await CropCycleService.get_cycle_by_id(db, payload.crop_cycle_id)
    print("DEBUG: get_cycle_by_id() CALLED WITH:", cycle)
    print("PLOT ID:", cycle.plot_id)

    if not cycle:
        raise HTTPException(status_code=404, detail="Crop cycle not found")

    plot = await PlotService.get_plot_by_id(db, cycle.plot_id)
    if not plot:
        raise HTTPException(status_code=404, detail="Plot not found")

    if plot.farmer_id != current_user.id:
        raise HTTPException(status_code=403, detail="You cannot create a claim for this plot")

    # ✅ FIXED: pass cycle into service
    claim = await ClaimService.create_claim(db, current_user.id, payload, cycle)

    return claim



# ---------------- GET CLAIM BY ID ----------------
@router.get("/{claim_id}", response_model=ClaimResponse)
async def get_claim(
    claim_id: UUID,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    claim = await ClaimService.get_claim_by_id(db, str(claim_id))
    if not claim:
        raise HTTPException(status_code=404, detail="Claim not found")

    # authorize farmer or admin
    if claim.farmer_id != current_user.id and current_user.role != "admin":
        raise HTTPException(status_code=403, detail="Not authorized")

    return claim



# ---------------- GET CLAIMS BY PLOT ----------------
@router.get("/plot/{plot_id}", response_model=List[ClaimResponse])
async def get_claims_by_plot(
    plot_id: UUID,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    plot = await PlotService.get_plot_by_id(db, str(plot_id))
    if not plot:
        raise HTTPException(status_code=404, detail="Plot not found")

    if plot.farmer_id != current_user.id and current_user.role != "admin":
        raise HTTPException(status_code=403, detail="Not authorized")

    return await ClaimService.get_claims_by_plot(db, str(plot_id))


# ---------------- UPDATE CLAIM ----------------
@router.put("/{claim_id}", response_model=ClaimResponse)
async def update_claim(
    claim_id: UUID,
    payload: ClaimUpdate,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    claim = await ClaimService.get_claim_by_id(db, str(claim_id))
    if not claim:
        raise HTTPException(status_code=404, detail="Claim not found")

    if claim.farmer_id != current_user.id:
        raise HTTPException(status_code=403, detail="Not authorized")

    if claim.status not in ("pending", "under_inspection"):
        raise HTTPException(status_code=400, detail="Claim cannot be edited at this stage")

    return await ClaimService.update_claim(db, str(claim_id), payload)


# ---------------- UPLOAD EVIDENCE ----------------
@router.post("/{claim_id}/upload-evidence")
async def upload_claim_evidence(
    claim_id: UUID,
    file: UploadFile = File(...),
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    claim = await ClaimService.get_claim_by_id(db, str(claim_id))
    if not claim:
        raise HTTPException(status_code=404, detail="Claim not found")

    if claim.farmer_id != current_user.id and current_user.role != "admin":
        raise HTTPException(status_code=403, detail="Not authorized")

    evidence = await ClaimService.add_evidence(db, str(claim_id), file)
    return {"message": "Evidence uploaded", "evidence": evidence}


