from fastapi import APIRouter, Depends, HTTPException, UploadFile, File
from typing import Optional, List
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.oauth import get_current_user
from app.core.database import get_db

from app.services.plot_service import PlotService
from app.schemas.plot_schema import PlotCreate, PlotUpdate, PlotResponse
from app.models.user import User

router = APIRouter( tags=["Plots"])


# --------------------------------------------------------
# CREATE PLOT
# --------------------------------------------------------
@router.post("/", response_model=PlotResponse)
async def create_plot(
    payload: PlotCreate,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    if current_user.role not in ["farmer", "admin"]:
        raise HTTPException(status_code=403, detail="Only farmers/admins can create plots")

    plot = await PlotService.create_plot(db, payload)
    return plot


# --------------------------------------------------------
# UPLOAD LAND DOCUMENT (Separate endpoint)
# --------------------------------------------------------
@router.post("/{plot_id}/upload-document", response_model=dict)
async def upload_plot_document(
    plot_id: str,
    land_doc: UploadFile = File(...),
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    return await PlotService.upload_land_document(db, plot_id, land_doc)


# --------------------------------------------------------
# GET ALL PLOTS OF CURRENT USER
# --------------------------------------------------------
@router.get("/me", response_model=List[PlotResponse])
async def get_my_plots(
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    return await PlotService.get_plots_by_farmer(db, current_user.id)


# --------------------------------------------------------
# GET PLOT BY ID
# --------------------------------------------------------
@router.get("/{plot_id}", response_model=PlotResponse)
async def get_plot(
    plot_id: str,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    plot = await PlotService.get_plot_by_id(db, plot_id)
    if not plot:
        raise HTTPException(status_code=404, detail="Plot not found")

    if plot.farmer_id != current_user.id and current_user.role != "admin":
        raise HTTPException(status_code=403, detail="Not authorized")

    return plot


# --------------------------------------------------------
# UPDATE PLOT
# --------------------------------------------------------
@router.put("/{plot_id}", response_model=PlotResponse)
async def update_plot(
    plot_id: str,
    payload: PlotUpdate,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    plot = await PlotService.get_plot_by_id(db, plot_id)
    if not plot:
        raise HTTPException(status_code=404, detail="Plot not found")

    if plot.farmer_id != current_user.id and current_user.role != "admin":
        raise HTTPException(status_code=403, detail="Not authorized")

    updated_plot = await PlotService.update_plot(db, plot_id, payload)
    return updated_plot


# --------------------------------------------------------
# DELETE PLOT
# --------------------------------------------------------
@router.delete("/{plot_id}")
async def delete_plot(
    plot_id: str,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    plot = await PlotService.get_plot_by_id(db, plot_id)
    if not plot:
        raise HTTPException(status_code=404, detail="Plot not found")

    if plot.farmer_id != current_user.id and current_user.role != "admin":
        raise HTTPException(status_code=403, detail="Not authorized")

    await PlotService.delete_plot(db, plot_id)
    return {"message": "Plot deleted successfully"}


# --------------------------------------------------------
# LOCATION VALIDATION
# --------------------------------------------------------
@router.get("/{plot_id}/validate-location")
async def validate_location(
    plot_id: str,
    lat: float,
    lng: float,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    return await PlotService.validate_location(db, plot_id, lat, lng)


@router.post("/{plot_id}/upload-document", response_model=dict)
async def upload_plot_document(
    plot_id: str,
    land_doc: UploadFile = File(...),
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    return await PlotService.upload_land_document(db, plot_id, land_doc)
