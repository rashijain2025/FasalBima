import cloudinary
import cloudinary.uploader
from app.core.config import settings

# Configure Cloudinary
cloudinary.config(
    cloud_name=settings.CLOUDINARY_CLOUD_NAME,
    api_key=settings.CLOUDINARY_API_KEY,
    api_secret=settings.CLOUDINARY_API_SECRET
)

# -----------------------------
# Function to upload images
# -----------------------------
def upload_image_to_cloudinary(file_path: str, folder: str = None) -> str:
    options = {}
    if folder:
        options['folder'] = folder

    result = cloudinary.uploader.upload(file_path, **options)
    return result.get("secure_url")

def upload_media_to_cloudinary(file_bytes, content_type):
    resource_type = "video" if content_type.startswith("video") else "image"
    
    return cloudinary.uploader.upload(
        file_bytes,
        resource_type=resource_type
    )["secure_url"]
