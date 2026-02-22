PROFILE_REQUIRED_RESPONSE = {
    "description": "Profile required before accessing this feature.",
    "content": {
        "application/json": {
            "example": {
                "detail": {
                    "code": "PROFILE_REQUIRED",
                    "message": "Complete profile first",
                    "details": None,
                }
            }
        }
    },
}

PROFILE_NOT_FOUND_RESPONSE = {
    "description": "The authenticated user profile does not exist.",
    "content": {
        "application/json": {
            "example": {
                "detail": {
                    "code": "PROFILE_NOT_FOUND",
                    "message": "Profile not found",
                    "details": None,
                }
            }
        }
    },
}
