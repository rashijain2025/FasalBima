from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.ext.asyncio import AsyncSession
from typing import List, Optional
from app.schemas.claim_schema import ClaimAdminReview
from uuid import UUID

from app.core.database import get_db
from app.core.oauth import get_current_user
from app.models.user import User
from app.schemas.user_schema import UserResponse

from app.schemas.plot_schema import PlotResponse
from app.schemas.crop_schema import CropCycleResponse
from app.schemas.claim_schema import ClaimResponse

from app.services.plot_service import PlotService
from app.services.crop_cycle_service import CropCycleService
from app.services.claim_service import ClaimService
from app.services.user_service import UserService

router = APIRouter(tags=["Admin"])


def _require_admin(current_user: User):
    if current_user.role != "admin":
        raise HTTPException(status_code=403, detail="Admin privileges required")
    return True


# ----------------------------------------------------------
# LIST PLOTS
# ----------------------------------------------------------
@router.get("/dashboard/plots", response_model=List[PlotResponse])
async def admin_list_plots(
    skip: int = 0,
    limit: int = 100,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    _require_admin(current_user)
    return await PlotService.list_all_plots(db, skip=skip, limit=limit)


# ----------------------------------------------------------
# LIST CROP CYCLES
# ----------------------------------------------------------
@router.get("/dashboard/crop-cycles", response_model=List[CropCycleResponse])
async def admin_list_crop_cycles(
    skip: int = 0,
    limit: int = 100,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    _require_admin(current_user)
    return await CropCycleService.list_all_cycles(db, skip=skip, limit=limit)


# ----------------------------------------------------------
# LIST CLAIMS
# ----------------------------------------------------------
@router.get("/dashboard/claims", response_model=List[ClaimResponse])
async def admin_list_claims(
    status: Optional[str] = Query(None),
    skip: int = 0,
    limit: int = 100,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    _require_admin(current_user)
    return await ClaimService.list_all_claims(db, status=status, skip=skip, limit=limit)


# ----------------------------------------------------------
# LIST FARMERS
# ----------------------------------------------------------
@router.get("/farmers", response_model=List[UserResponse])
async def admin_list_farmers(
    skip: int = 0,
    limit: int = 100,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    _require_admin(current_user)
    return await UserService.list_farmers(db, skip=skip, limit=limit)


# ----------------------------------------------------------
# VERIFY FARMER
# ----------------------------------------------------------
@router.post("/verify-farmer/{farmer_id}")
async def admin_verify_farmer(
    farmer_id: str,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    _require_admin(current_user)

    farmer = await UserService.get_user_by_id(db, farmer_id)
    if not farmer:
        raise HTTPException(status_code=404, detail="Farmer not found")

    await UserService.verify_farmer(db, farmer_id)
    return {"message": "Farmer verified"}


# ----------------------------------------------------------
# VERIFY PLOT
# ----------------------------------------------------------
@router.post("/verify-plot/{plot_id}")
async def admin_verify_plot(
    plot_id: str,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    _require_admin(current_user)

    plot = await PlotService.get_plot_by_id(db, plot_id)
    if not plot:
        raise HTTPException(status_code=404, detail="Plot not found")

    await PlotService.verify_plot(db, plot_id)
    return {"message": "Plot verified"}


# ----------------------------------------------------------
# VERIFY CLAIM
# ----------------------------------------------------------
@router.post("/verify-claim/{claim_id}")
async def admin_review_claim(
    claim_id: UUID,
    payload: ClaimAdminReview,   # ← Accept JSON body here
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)

):
    print(current_user.role)
    if current_user.role != "admin":
        raise HTTPException(status_code=403, detail="Admin privileges required")

    # Get claim
    claim = await ClaimService.get_claim_by_id(db, str(claim_id))
    if not claim:
        raise HTTPException(status_code=404, detail="Claim not found")

    # Determine status
    status = "approved" if payload.approve else "rejected"

    # Update claim
    return await ClaimService.set_claim_status(
        db=db,
        claim_id=str(claim_id),
        status=status,
        admin_notes=payload.admin_notes,
        admin_id=current_user.id
    )