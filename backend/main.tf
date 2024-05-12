resource "aws_s3_bucket" "backend" {
  bucket = var.bucket_name

  tags = {
    Name        = "Terraform State Bucket"
    Environment = "Terraform Backend"
  }
}

resource "aws_s3_bucket_versioning" "versioning" {
  bucket = aws_s3_bucket.backend.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "lifecycle" {
  bucket = aws_s3_bucket.backend.id

  rule {
    id     = "lifecycle_rule"
    status = "Enabled"

    noncurrent_version_expiration {
      noncurrent_days = 90
    }

    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }
  }
}
