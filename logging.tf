resource "aws_s3_bucket" "logs" {
  count  = var.enable_logging ? 1 : 0
  bucket = "${var.bucket_name}-logs"
  tags   = var.tags
}

resource "aws_s3_bucket_public_access_block" "logs" {
  count  = var.enable_logging ? 1 : 0
  bucket = aws_s3_bucket.logs[0].id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# CloudFront's standard access logging still delivers via an S3 ACL grant,
# so the destination bucket needs ACLs enabled rather than the
# bucket-owner-enforced default.
resource "aws_s3_bucket_ownership_controls" "logs" {
  count  = var.enable_logging ? 1 : 0
  bucket = aws_s3_bucket.logs[0].id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

data "aws_canonical_user_id" "current" {
  count = var.enable_logging ? 1 : 0
}

resource "aws_s3_bucket_acl" "logs" {
  count      = var.enable_logging ? 1 : 0
  depends_on = [aws_s3_bucket_ownership_controls.logs]
  bucket     = aws_s3_bucket.logs[0].id

  access_control_policy {
    grant {
      grantee {
        id   = data.aws_canonical_user_id.current[0].id
        type = "CanonicalUser"
      }
      permission = "FULL_CONTROL"
    }

    grant {
      grantee {
        # AWS's fixed canonical user ID for the CloudFront/S3 log delivery account.
        id   = "c4c1ede66af53448b93c283ce9448c4ba468c9432aa01d700d3878632f77d2d"
        type = "CanonicalUser"
      }
      permission = "FULL_CONTROL"
    }

    owner {
      id = data.aws_canonical_user_id.current[0].id
    }
  }
}
