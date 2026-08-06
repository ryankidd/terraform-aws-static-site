output "bucket_id" {
  description = "ID of the S3 bucket storing site content."
  value       = aws_s3_bucket.site.id
}

output "bucket_arn" {
  description = "ARN of the S3 bucket storing site content."
  value       = aws_s3_bucket.site.arn
}
