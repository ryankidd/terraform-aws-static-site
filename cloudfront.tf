resource "aws_cloudfront_origin_access_control" "site" {
  name                              = var.bucket_name
  description                       = "OAC for ${var.bucket_name}"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

data "aws_cloudfront_response_headers_policy" "security_headers" {
  name = "Managed-SecurityHeadersPolicy"
}

resource "aws_cloudfront_distribution" "site" {
  #checkov:skip=CKV_AWS_68:WAF is a paid add-on out of scope for this module; attach a WAF web ACL to the distribution ARN outside the module if needed.
  #checkov:skip=CKV_AWS_310:Single S3 origin by design; origin failover would need a second origin this module doesn't create.
  #checkov:skip=CKV_AWS_374:No geo restriction by default is intentional so the site is reachable from anywhere; set restrictions per deployment if needed.
  #checkov:skip=CKV2_AWS_47:No WAF is attached (see CKV_AWS_68), so there's no web ACL to configure an AMR rule on.
  enabled             = true
  default_root_object = var.default_root_object
  price_class         = var.price_class
  aliases             = var.domain_aliases
  tags                = var.tags

  origin {
    domain_name              = aws_s3_bucket.site.bucket_regional_domain_name
    origin_id                = local.origin_id
    origin_access_control_id = aws_cloudfront_origin_access_control.site.id
  }

  default_cache_behavior {
    allowed_methods            = ["GET", "HEAD"]
    cached_methods             = ["GET", "HEAD"]
    target_origin_id           = local.origin_id
    viewer_protocol_policy     = "redirect-to-https"
    compress                   = true
    response_headers_policy_id = data.aws_cloudfront_response_headers_policy.security_headers.id

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }
  }

  dynamic "logging_config" {
    for_each = var.enable_logging ? [1] : []

    content {
      bucket = aws_s3_bucket.logs[0].bucket_domain_name
      prefix = "cloudfront/"
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = var.acm_certificate_arn == null
    acm_certificate_arn            = var.acm_certificate_arn
    ssl_support_method             = var.acm_certificate_arn == null ? null : "sni-only"
    minimum_protocol_version       = var.acm_certificate_arn == null ? null : "TLSv1.2_2021"
  }

  lifecycle {
    precondition {
      condition     = length(var.domain_aliases) == 0 || var.acm_certificate_arn != null
      error_message = "acm_certificate_arn must be set when domain_aliases is non-empty."
    }
  }
}
