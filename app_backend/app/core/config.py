from pydantic_settings import BaseSettings
from typing import List


class Settings(BaseSettings):
    # Database
    DATABASE_URL: str

    # JWT
    JWT_SECRET_KEY: str                    # <--- MATCHED YOUR .env
    JWT_ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 60
    REFRESH_TOKEN_EXPIRE_DAYS: int = 30

    # CORS
    BACKEND_CORS_ORIGINS: List[str] = ["*"]

    # Cloudinary
    CLOUDINARY_CLOUD_NAME: str
    CLOUDINARY_API_KEY: str
    CLOUDINARY_API_SECRET: str

    model_config = {
        "env_file": ".env",
        "env_file_encoding": "utf-8",
        "extra": "allow"   # avoid future errors if extra env vars exist
    }


settings = Settings()
