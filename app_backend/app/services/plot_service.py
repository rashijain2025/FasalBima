# app/services/plot_service.py

import uuid
from uuid import UUID
from typing import Optional

from fastapi import UploadFile, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.orm import Session
from sqlalchemy import select, delete

from shapely.geometry import Point, Polygon
from geoalchemy2.shape import to_shape  # REQUIRED

from app.models.plot import Plot
from app.schemas.plot_schema import PlotCreate, PlotUpdate
from sqlalchemy import select
from sqlalchemy.orm import selectinload
from app.utils.cloudinary_upload import upload_image_to_cloudinary


class PlotService:

    # ------------------------------------------------------
    # CREATE PLOT
    # ------------------------------------------------------
    @staticmethod
    async def create_plot(
        db: AsyncSession,
        payload: PlotCreate,
        document_file: Optional[bytes] = None
    ):
        polygon_ewkt = None
        centroid_ewkt = None

        if payload.boundary_coordinates:
            coords = [(lng, lat) for lat, lng in payload.boundary_coordinates]
            polygon = Polygon(coords)

            polygon_ewkt = f"SRID=4326;{polygon.wkt}"
            centroid_ewkt = f"SRID=4326;{polygon.centroid.wkt}"

        land_url = None
        if document_file:
            land_url = await upload_image_to_cloudinary(document_file)

        new_plot = Plot(
            id=uuid.uuid4(),
            farmer_id=payload.farmer_id,
            plot_name=payload.plot_name,
            address=payload.address,
            village=payload.village,
            district=payload.district,
            state=payload.state,
            country=payload.country,
            area_hectares=payload.area_hectares,
            boundary_coordinates=payload.boundary_coordinates,
            polygon=polygon_ewkt,
            centroid=centroid_ewkt,
            land_document_url=land_url,
            land_document_type=payload.land_document_type,
            is_verified=False,
        )

        db.add(new_plot)
        await db.commit()
        await db.refresh(new_plot)
        return new_plot

    # ------------------------------------------------------
    # GET PLOT BY ID
    # ------------------------------------------------------
    @staticmethod
    async def get_plot_by_id(db: AsyncSession, plot_id):
        # Accept UUID or str
        if isinstance(plot_id, UUID):
            uuid_val = plot_id
        else:
            try:
                uuid_val = UUID(str(plot_id))
            except:
                return None

        result = await db.execute(select(Plot).where(Plot.id == uuid_val))
        return result.scalar_one_or_none()

    # ------------------------------------------------------
    # GET PLOTS FOR FARMER
    # ------------------------------------------------------
    @staticmethod
    async def get_plots_by_farmer(db: AsyncSession, farmer_id: uuid.UUID):
        result = await db.execute(select(Plot).where(Plot.farmer_id == farmer_id))
        return result.scalars().all()

    # ------------------------------------------------------
    # UPDATE PLOT
    # ------------------------------------------------------
    @staticmethod
    async def update_plot(
        db: AsyncSession,
        plot_id: str,
        payload: PlotUpdate,
        document_file: Optional[bytes] = None
    ):
        plot = await PlotService.get_plot_by_id(db, plot_id)
        if not plot:
            return None

        update_data = payload.dict(exclude_unset=True)

        if document_file:
            plot.land_document_url = await upload_image_to_cloudinary(document_file)

        if "boundary_coordinates" in update_data:
            coords = [(lng, lat) for lat, lng in update_data["boundary_coordinates"]]
            polygon = Polygon(coords)

            plot.polygon = f"SRID=4326;{polygon.wkt}"
            plot.centroid = f"SRID=4326;{polygon.centroid.wkt}"

        for key, value in update_data.items():
            setattr(plot, key, value)

        await db.commit()
        await db.refresh(plot)
        return plot

    # ------------------------------------------------------
    # DELETE PLOT
    # ------------------------------------------------------
    @staticmethod
    async def delete_plot(db: AsyncSession, plot_id: str):
        try:
            uuid_val = UUID(plot_id)
        except:
            return False

        await db.execute(delete(Plot).where(Plot.id == uuid_val))
        await db.commit()
        return True

    # ------------------------------------------------------
    # UPLOAD LAND DOCUMENT
    # ------------------------------------------------------
    @staticmethod
    async def upload_land_document(
        db: AsyncSession,
        plot_id: str,
        file: UploadFile
    ):
        plot = await PlotService.get_plot_by_id(db, plot_id)
        if not plot:
            raise HTTPException(status_code=404, detail="Plot not found")

        contents = await file.read()
        url = await upload_image_to_cloudinary(contents)

        plot.land_document_url = url
        await db.commit()
        await db.refresh(plot)

        return {
            "message": "Document uploaded successfully",
            "document_url": url
        }

    # ------------------------------------------------------
    # VALIDATE LOCATION
    # ------------------------------------------------------
    @staticmethod
    async def validate_location(
        db: AsyncSession,
        plot_id: str,
        lat: float,
        lng: float
    ):
        plot = await PlotService.get_plot_by_id(db, plot_id)

        if not plot:
            return {"error": "Plot not found"}

        if not plot.polygon:
            return {"error": "Plot has no polygon geometry"}

        try:
            polygon = to_shape(plot.polygon)
        except Exception as e:
            return {"error": f"Invalid polygon format: {str(e)}"}

        point = Point(lng, lat)

        if polygon.contains(point):
            return {
                "inside": True,
                "distance_meters": 0,
                "message": "Inside plot boundary"
            }

        distance_deg = point.distance(polygon)
        distance_meters = distance_deg * 111139

        if distance_meters <= 50:
            return {
                "inside": False,
                "distance_meters": round(distance_meters, 2),
                "message": "Near boundary (<50m)"
            }

        return {
            "inside": False,
            "distance_meters": round(distance_meters, 2),
            "message": "Outside plot boundary"
        }

    # ------------------------------------------------------
    # LIST ALL PLOTS (SYNC DB)
    # ------------------------------------------------------
    @staticmethod
    async def list_all_plots(db: AsyncSession, skip: int = 0, limit: int = 100):
     stmt = (
        select(Plot)
        .options(selectinload(Plot.crop_cycles))   # optional relations
        .offset(skip)
        .limit(limit)
     )

     result = await db.execute(stmt)
     return result.scalars().all()
    # ------------------------------------------------------
    # VERIFY PLOT (ADMIN ACTION)
    # ------------------------------------------------------
    @staticmethod
    async def verify_plot(db: AsyncSession, plot_id: str, is_verified: bool = True):
        plot = await PlotService.get_plot_by_id(db, plot_id)
        if not plot:
            raise HTTPException(status_code=404, detail="Plot not found")

        plot.is_verified = is_verified
        await db.commit()
        await db.refresh(plot)

        return {
            "message": "Plot verification updated successfully",
            "plot_id": str(plot.id),
            "is_verified": plot.is_verified
        }