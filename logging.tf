resource "aws_s3_bucket" "logs" {
  #checkov:skip=CKV_AWS_144:Single-region bucket by design; replication is unnecessary for a log destination that already expires objects after 90 days.
  #checkov:skip=CKV_AWS_145:Objects get default SSE-S3 encryption; requiring a customer-managed KMS key adds cost and rotation overhead this module doesn't assume by default.
  #checkov:skip=CKV2_AWS_62:No event-driven processing pipeline in scope for the log bucket.
  #checkov:skip=CKV_AWS_21:Log objects are write-once and expired via the lifecycle rule below; version history adds no value here.
  #checkov:skip=CKV_AWS_18:This is already the log destination bucket; enabling access logging on it would be circular.
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

resource "aws_s3_bucket_lifecycle_configuration" "logs" {
  count  = var.enable_logging ? 1 : 0
  bucket = aws_s3_bucket.logs[0].id

  rule {
    id     = "expire-access-logs"
    status = "Enabled"

    filter {}

    expiration {
      days = 90
    }
  }
}

# CloudFront's standard access logging still delivers via an S3 ACL grant,
# so the destination bucket needs ACLs enabled rather than the
# bucket-owner-enforced default.
resource "aws_s3_bucket_ownership_controls" "logs" {
  #checkov:skip=CKV2_AWS_65:ACLs are intentionally enabled on this bucket; CloudFront's standard access-logging delivery requires ACL-based grants on the destination bucket.
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
