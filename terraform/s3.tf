# INTENTIONALLY INSECURE: Public-readable S3 bucket for MongoDB backups
resource "aws_s3_bucket" "mongodb_backups" {
  bucket        = "${var.project_name}-mongodb-backups-${data.aws_caller_identity.current.account_id}"
  force_destroy = true

  tags = {
    Name = "${var.project_name}-mongodb-backups"
  }
}

# VULNERABILITY: Public read access
resource "aws_s3_bucket_public_access_block" "mongodb_backups" {
  bucket = aws_s3_bucket.mongodb_backups.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

# VULNERABILITY: Bucket policy allows public listing and reading
resource "aws_s3_bucket_policy" "mongodb_backups" {
  bucket = aws_s3_bucket.mongodb_backups.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "PublicReadGetObject"
        Effect = "Allow"
        Principal = "*"
        Action = [
          "s3:GetObject",
          "s3:ListBucket"
        ]
        Resource = [
          aws_s3_bucket.mongodb_backups.arn,
          "${aws_s3_bucket.mongodb_backups.arn}/*"
        ]
      }
    ]
  })

  depends_on = [aws_s3_bucket_public_access_block.mongodb_backups]
}

# Enable versioning (good practice, but bucket is still public)
resource "aws_s3_bucket_versioning" "mongodb_backups" {
  bucket = aws_s3_bucket.mongodb_backups.id

  versioning_configuration {
    status = "Enabled"
  }
}

# Lifecycle rule to delete old backups after 30 days
resource "aws_s3_bucket_lifecycle_configuration" "mongodb_backups" {
  bucket = aws_s3_bucket.mongodb_backups.id

  rule {
    id     = "delete-old-backups"
    status = "Enabled"

    expiration {
      days = 30
    }

    noncurrent_version_expiration {
      noncurrent_days = 7
    }
  }
}

# S3 bucket for CodePipeline artifacts
resource "aws_s3_bucket" "codepipeline_artifacts" {
  bucket        = "${var.project_name}-pipeline-artifacts-${data.aws_caller_identity.current.account_id}"
  force_destroy = true

  tags = {
    Name = "${var.project_name}-pipeline-artifacts"
  }
}

resource "aws_s3_bucket_public_access_block" "codepipeline_artifacts" {
  bucket = aws_s3_bucket.codepipeline_artifacts.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "codepipeline_artifacts" {
  bucket = aws_s3_bucket.codepipeline_artifacts.id

  versioning_configuration {
    status = "Enabled"
  }
}

output "mongodb_backup_bucket" {
  description = "S3 bucket for MongoDB backups"
  value       = aws_s3_bucket.mongodb_backups.bucket
}

output "mongodb_backup_bucket_url" {
  description = "Public URL to list MongoDB backups"
  value       = "https://${aws_s3_bucket.mongodb_backups.bucket}.s3.amazonaws.com/"
}
