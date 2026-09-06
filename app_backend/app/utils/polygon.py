# utils/polygon.py
from shapely.geometry import Polygon


def build_polygon_wkt(boundary_coordinates):
    """
    boundary_coordinates = [[lat, lon], [lat, lon], ...]
    returns polygon_wkt, centroid_wkt
    """

    if not boundary_coordinates or len(boundary_coordinates) < 3:
        return None, None

    # Convert to (lon, lat)
    polygon = Polygon([(lon, lat) for lat, lon in boundary_coordinates])

    if not polygon.is_valid:
        polygon = polygon.buffer(0)  # Fix self-intersections

    return polygon.wkt, polygon.centroid.wkt
