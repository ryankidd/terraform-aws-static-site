output "bucket_id" {
  description = "ID of the S3 bucket storing site content."
  value       = aws_s3_bucket.site.id
}

output "bucket_arn" {
  description = "ARN of the S3 bucket storing site content."
  value       = aws_s3_bucket.site.arn
}

output "distribution_id" {
  description = "ID of the CloudFront distribution."
  value       = aws_cloudfront_distribution.site.id
}

output "distribution_domain_name" {
  description = "Domain name of the CloudFront distribution."
  value       = aws_cloudfront_distribution.site.domain_name
}

output "logs_bucket_id" {
  description = "ID of the S3 bucket storing CloudFront access logs, if enable_logging is true."
  value       = try(aws_s3_bucket.logs[0].id, null)
}
