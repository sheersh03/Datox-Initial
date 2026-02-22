import boto3
from botocore.config import Config
from app.core.config import settings

def _client():
    return boto3.client(
        "s3",
        endpoint_url=settings.S3_ENDPOINT,
        aws_access_key_id=settings.S3_ACCESS_KEY,
        aws_secret_access_key=settings.S3_SECRET_KEY,
        region_name=settings.S3_REGION,
        config=Config(signature_version="s3v4"),
    )

def ensure_bucket():
    s3 = _client()
    try:
        s3.head_bucket(Bucket=settings.S3_BUCKET)
    except Exception:
        s3.create_bucket(Bucket=settings.S3_BUCKET)

def presign_put(key: str, content_type: str = "image/jpeg", expires: int = 600) -> str:
    s3 = _client()
    return s3.generate_presigned_url(
        ClientMethod="put_object",
        Params={"Bucket": settings.S3_BUCKET, "Key": key, "ContentType": content_type},
        ExpiresIn=expires,
    )

def public_url(key: str) -> str:
    base = settings.S3_PUBLIC_BASE_URL.rstrip("/")
    return f"{base}/{key}"
