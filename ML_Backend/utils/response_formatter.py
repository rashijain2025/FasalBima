# utils/response_formatter.py

def format_quality_response(quality_label: str):
    """
    Returned when quality != good.
    No further ML processing is done.
    """
    return {
        "success": False,
        "message": "Poor image quality",
        "quality": quality_label,
        "instruction": "Please retake the image clearly inside your farmland."
    }


def final_response(
    quality: str,
    crop_type: str,
    stage: str,
    stage_confidence: float,
    stress_class: str,
    stress_confidence: float,
    severity: float,
    severity_label: str
):
    return {
        "quality": quality,
        "crop_type": crop_type,
        "stage": stage,
        "stage_confidence": stage_confidence,
        "stress_class": stress_class,
        "stress_confidence": stress_confidence,
        "severity": severity,
        "severity_label": severity_label
    }
