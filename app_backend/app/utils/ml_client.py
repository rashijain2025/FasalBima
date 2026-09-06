import httpx

ML_BACKEND_URL = "http://127.0.0.1:8001/api/predict"

async def call_ml_service(image_bytes: bytes, lat: float, lng: float):
    try:
        async with httpx.AsyncClient(timeout=120) as client:
            res = await client.post(
                ML_BACKEND_URL,
                files={"file": ("image.jpg", image_bytes, "image/jpeg")},
                data={"user_lat": lat, "user_lng": lng}
            )

        return res.json()

    except Exception as e:
        print("ML BACKEND ERROR:", e)
        return None
