# utils/geocode.py
import httpx

NOMINATIM_URL = "https://nominatim.openstreetmap.org/search"


async def geocode_address(address: str):
    """
    Convert farmer's address → coordinates (lat, lon)
    Uses OpenStreetMap Nominatim API, suitable for production with rate limits.
    """

    async with httpx.AsyncClient(timeout=10) as client:
        response = await client.get(
            NOMINATIM_URL,
            params={
                "q": address,
                "format": "json",
                "limit": 1
            },
            headers={"User-Agent": "CropInsuranceApp/1.0"}
        )

        data = response.json()

        if not data:
            return None

        return {
            "lat": float(data[0]["lat"]),
            "lon": float(data[0]["lon"])
        }
