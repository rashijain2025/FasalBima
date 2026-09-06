# app/services/geo_service.py

import uuid
from geoalchemy2.shape import to_shape
from shapely.geometry import Point
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession
from shapely.ops import nearest_points
from app.models.plot import Plot


class GeoService:

    @staticmethod
    async def is_within_polygon(db: AsyncSession, plot_id: str, lat: float, lng: float):

        # Validate lat/lng
        if not (-90 <= lat <= 90 and -180 <= lng <= 180):
            return {"inside": False, "reason": "Invalid coordinates"}

        # Convert ID → UUID
        try:
            uuid_val = uuid.UUID(plot_id)
        except:
            return {"inside": False, "reason": "Invalid plot ID"}

        result = await db.execute(select(Plot).where(Plot.id == uuid_val))
        plot = result.scalar_one_or_none()

        if not plot:
            return {"inside": False, "reason": "Plot not found"}

        if not plot.polygon:
            return {"inside": False, "reason": "Plot has no boundary"}

        try:
            polygon = to_shape(plot.polygon)
        except Exception as e:
            return {"inside": False, "reason": f"Polygon parse error: {str(e)}"}

        point = Point(lng, lat)

        # Case 1: inside polygon
        if polygon.contains(point):
            return {"inside": True, "distance_m": 0}

        # Case 2: on boundary → treat as inside
        if polygon.touches(point):
            return {"inside": True, "distance_m": 0}

        # Case 3: within tolerance (30 meters)
        # 1 degree ≈ 111139 meters
        distance_deg = polygon.exterior.distance(point)
        distance_m = distance_deg * 111139

        if distance_m <= 30:
            return {
                "inside": True,
                "near_boundary": True,
                "distance_m": round(distance_m, 2)
            }

        # Case 4: outside plot
        return {
            "inside": False,
            "distance_m": round(distance_m, 2)
        }
