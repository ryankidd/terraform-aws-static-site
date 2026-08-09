resource "aws_s3_bucket" "site" {
  #checkov:skip=CKV_AWS_144:Single-region bucket by design; replication is a per-deployment decision this module shouldn't force on every consumer.
  #checkov:skip=CKV_AWS_145:Objects get default SSE-S3 encryption; requiring a customer-managed KMS key adds cost and rotation overhead this module doesn't assume by default.
  #checkov:skip=CKV2_AWS_62:No event-driven processing pipeline in scope for a static site bucket.
  #checkov:skip=CKV2_AWS_61:Site content isn't time-based; a lifecycle policy for expiring or transitioning objects is a per-deployment decision.
  #checkov:skip=CKV_AWS_18:Bucket is private and only reachable via CloudFront through the OAC in cloudfront.tf; enable var.enable_logging for CloudFront-level access logs instead.
  bucket = var.bucket_name
  tags   = var.tags
}

resource "aws_s3_bucket_public_access_block" "site" {
  bucket = aws_s3_bucket.site.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "site" {
  bucket = aws_s3_bucket.site.id

  versioning_configuration {
    status = "Enabled"
  }
}
