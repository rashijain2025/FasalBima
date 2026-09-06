from shapely.geometry import Point, Polygon

class GeoLocationService:

    def __init__(self, tolerance=15):  
        # 15m buffer for GPS drift
        self.tolerance = tolerance  

    def is_inside_farm(self, user_lat, user_lng, polygon_coords):
        """
        polygon_coords: [(lat, lng), (lat, lng), ...]
        """

        # Validate polygon
        if not polygon_coords or len(polygon_coords) < 3:
            return False  # Cannot form a polygon

        # Convert (lat, lng) → (lng, lat) because shapely expects x=lng, y=lat
        try:
            polygon_points = [(lng, lat) for lat, lng in polygon_coords]
        except Exception:
            return False

        try:
            farm_poly = Polygon(polygon_points)
        except Exception:
            return False

        # Create user point
        user_point = Point(user_lng, user_lat)

        # Apply tolerance buffer
        # 1 degree ≈ 111,000 meters
        buffer_distance = self.tolerance / 111000
        farm_poly_buffered = farm_poly.buffer(buffer_distance)

        # Convert shapely boolean → real Python boolean
        return bool(farm_poly_buffered.contains(user_point))
