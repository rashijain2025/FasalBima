from sqlalchemy.ext.asyncio import create_async_engine, AsyncSession
from sqlalchemy.orm import sessionmaker, declarative_base
from app.core.config import settings

# ----------------------------------------
# FIX: Make DB engine safe for Neon/AsyncPG
# ----------------------------------------
engine = create_async_engine(
    settings.DATABASE_URL,
    echo=False,
    future=True,
    pool_pre_ping=True,       # Detect dead connections
    pool_recycle=1800,        # Recycle connection every 30 min
    pool_size=5,
    max_overflow=10
)

SessionLocal = sessionmaker(
    bind=engine,
    class_=AsyncSession,
    expire_on_commit=False,
    autoflush=False,          # safer for async operations
)

Base = declarative_base()

# ----------------------------------------
# FIX: Ensure session always closes properly
# ----------------------------------------
async def get_db():
    async with SessionLocal() as session:
        try:
            yield session
        finally:
            await session.close()
