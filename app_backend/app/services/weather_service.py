import aiohttp
import os
from dotenv import load_dotenv

load_dotenv()

class WeatherService:
    BASE_URL = "https://api.openweathermap.org/data/2.5"
    API_KEY = os.getenv("OPENWEATHER_API_KEY")

    async def fetch(self, url: str):
        if not self.API_KEY:
            raise ValueError("Missing OPENWEATHER_API_KEY in environment variables")

        async with aiohttp.ClientSession() as session:
            async with session.get(url) as response:
                if response.status != 200:
                    text = await response.text()
                    raise Exception(f"Weather API error: {response.status}, {text}")

                return await response.json()

    async def get_current_weather(self, lat: float, lon: float):
        """
        Returns real-time temperature, humidity, wind, etc.
        """
        url = (
            f"{self.BASE_URL}/weather?lat={lat}&lon={lon}"
            f"&appid={self.API_KEY}&units=metric"
        )

        data = await self.fetch(url)

        return {
            "location": data.get("name"),
            "temperature": data["main"]["temp"],
            "humidity": data["main"]["humidity"],
            "wind_speed": data["wind"]["speed"],
            "weather": data["weather"][0]["description"],
            "icon": data["weather"][0]["icon"],
        }

    async def get_forecast(self, lat: float, lon: float):
        """
        Returns 7-day forecast
        """
        url = (
            f"{self.BASE_URL}/forecast?lat={lat}&lon={lon}"
            f"&appid={self.API_KEY}&units=metric"
        )

        data = await self.fetch(url)

        # Process forecast (3-hour interval → grouped daily)
        daily_forecast = {}

        for entry in data["list"]:
            date_str = entry["dt_txt"].split(" ")[0]

            if date_str not in daily_forecast:
                daily_forecast[date_str] = {
                    "min_temp": entry["main"]["temp_min"],
                    "max_temp": entry["main"]["temp_max"],
                    "weather": entry["weather"][0]["description"],
                    "icon": entry["weather"][0]["icon"],
                }
            else:
                daily_forecast[date_str]["min_temp"] = min(
                    daily_forecast[date_str]["min_temp"],
                    entry["main"]["temp_min"]
                )
                daily_forecast[date_str]["max_temp"] = max(
                    daily_forecast[date_str]["max_temp"],
                    entry["main"]["temp_max"]
                )

        return daily_forecast
