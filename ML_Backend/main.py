# main.py
from fastapi import FastAPI, Request
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
import uvicorn

# Routers
from routers.predict_router import router as predict_router


def create_application() -> FastAPI:
    """Factory function to create FastAPI app (best practice)."""
    app = FastAPI(
        title="Fasal Bima - ML Backend",
        description="ML inference for crop quality, crop type, stage, disease, severity, and geo-boundary checks.",
        version="1.0.0"
    )

    # ---------------------------------------------------------
    # CORS CONFIG
    # ---------------------------------------------------------
    app.add_middleware(
        CORSMiddleware,
        allow_origins=["*"],      # ⚠️ In production -> restrict domains
        allow_credentials=True,
        allow_methods=["*"],
        allow_headers=["*"],
    )

    # ---------------------------------------------------------
    # ROUTERS
    # ---------------------------------------------------------
    app.include_router(predict_router, prefix="/api")

    # ---------------------------------------------------------
    # BASIC ROUTES
    # ---------------------------------------------------------
    @app.get("/", tags=["Health"])
    async def root():
        return {
            "status": "running",
            "service": "Fasal Bima ML Backend",
            "version": "1.0.0"
        }

    @app.get("/health", tags=["Health"])
    async def health_check():
        return {"status": "ok"}

    # ---------------------------------------------------------
    # GLOBAL EXCEPTION HANDLER
    # ---------------------------------------------------------
    @app.exception_handler(Exception)
    async def global_exception_handler(request: Request, exc: Exception):
        return JSONResponse(
            status_code=500,
            content={
                "error": "Internal Server Error",
                "details": str(exc),
                "path": request.url.path,
            }
        )

    return app


# Create the application instance
app = create_application()


# ---------------------------------------------------------
# PRODUCTION ENTRYPOINT
# ---------------------------------------------------------
if __name__ == "__main__":
    uvicorn.run(
        "main:app",
        host="0.0.0.0",
        port=8000,
        workers=1,      # Keep 1 for GPU-based inference
        reload=False
    )
