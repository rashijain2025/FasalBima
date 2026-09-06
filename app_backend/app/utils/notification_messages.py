# app/utils/notification_messages.py

def generate_crop_prediction_message(label: str) -> str:
    """
    Returns a friendly notification message based on ML prediction label.
    """

    if not label:
        return "A new crop update is available. Check your dashboard."

    label = label.lower()

    match label:
        case "healthy":
            return "Your crop is healthy. No issues detected."

        case "disease":
            return "Disease symptoms detected. Please inspect your crop."

        case "pest_damage":
            return "Pest damage detected. Consider taking preventive measures."

        case "water_stress":
            return "Water stress detected. Adjust irrigation immediately."

        case "lodging":
            return "Crop lodging detected. Provide plant support."

        case "nutrient_deficiency":
            return "Nutrient deficiency detected. Consider applying nutrient inputs."

        case "flood_damage":
            return "Flood damage detected. Inspect field conditions."

        case _:
            return "A new crop analysis result is available."
def claim_status_message(status: str, claim_id: str):
    status = status.lower()

    if status == "approved":
        return {
            "title": "Claim Approved",
            "message": f"Your claim #{claim_id} has been approved. The compensation will be processed soon."
        }

    if status == "rejected":
        return {
            "title": "Claim Rejected",
            "message": f"Your claim #{claim_id} has been rejected. Please check the admin notes for details."
        }

    if status == "in_review":
        return {
            "title": "Claim Under Review",
            "message": f"Your claim #{claim_id} is currently being reviewed by our team."
        }

    return {
        "title": "Claim Updated",
        "message": f"Your claim #{claim_id} status has been updated to '{status}'."
    }
