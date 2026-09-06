# app/core/security.py

from datetime import datetime, timedelta
import jwt as pyjwt   # <-- Explicitly use PyJWT
import bcrypt
from app.core.config import settings

# -----------------------------
# PASSWORD HASHING
# -----------------------------
def hash_password(password: str) -> str:
    """
    Hash password using bcrypt.
    """
    pwd_bytes = password.encode("utf-8")[:72]
    salt = bcrypt.gensalt()
    return bcrypt.hashpw(pwd_bytes, salt).decode("utf-8")


def verify_password(plain_password: str, hashed_password: str) -> bool:
    """
    Verify password against stored bcrypt hash.
    Also handles passlib bcrypt_sha256 if needed.
    """
    try:
        pwd_bytes = plain_password.encode("utf-8")[:72]
        hash_bytes = hashed_password.encode("utf-8")
        return bcrypt.checkpw(pwd_bytes, hash_bytes)
    except Exception:
        # Fallback for passlib hashes if any exist
        try:
            from passlib.context import CryptContext
            ctx = CryptContext(schemes=["bcrypt_sha256", "bcrypt"], deprecated="auto")
            return ctx.verify(plain_password, hashed_password)
        except Exception:
            return False


# -----------------------------
# JWT TOKEN CREATION (PyJWT)
# -----------------------------
def create_access_token(user_id: str):
    payload = {
        "sub": user_id,
        "exp": datetime.utcnow() + timedelta(days=1)
    }
    token = pyjwt.encode(
        payload,
        settings.JWT_SECRET_KEY,
        algorithm=settings.JWT_ALGORITHM
    )
    
    # PyJWT>=2 returns a string, <=1 returns bytes → normalize:
    if isinstance(token, bytes):
        token = token.decode("utf-8")
    
    return token
