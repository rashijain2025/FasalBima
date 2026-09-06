from fastapi import APIRouter, HTTPException
from app.services.weather_service import WeatherService

router = APIRouter()

weather_service = WeatherService()

@router.get("/current")
async def get_current_weather(lat: float, lon: float):
    """
    Get current weather by latitude & longitude
    """
    try:
        weather = await weather_service.get_current_weather(lat, lon)
        return {"success": True, "data": weather}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.get("/forecast")
async def get_weather_forecast(lat: float, lon: float):
    """
    Get 7-day weather forecast by latitude & longitude
    """
    try:
        forecast = await weather_service.get_forecast(lat, lon)
        return {"success": True, "data": forecast}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
