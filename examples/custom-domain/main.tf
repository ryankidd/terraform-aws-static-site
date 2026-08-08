terraform {
  required_version = ">= 1.5"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

provider "aws" {
  region = "us-west-2"
}

# CloudFront only accepts ACM certificates issued in us-east-1, regardless
# of where the rest of the stack lives, so the certificate is provisioned
# through an aliased provider.
provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"
}

variable "domain_name" {
  description = "Domain name to serve the site on, e.g. www.example.com."
  type        = string
  default     = "www.example.com"
}

variable "zone_name" {
  description = "Route 53 hosted zone that domain_name belongs to, e.g. example.com."
  type        = string
  default     = "example.com"
}

data "aws_route53_zone" "site" {
  name         = var.zone_name
  private_zone = false
}

resource "aws_acm_certificate" "site" {
  provider          = aws.us_east_1
  domain_name       = var.domain_name
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.site.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  zone_id         = data.aws_route53_zone.site.zone_id
  name            = each.value.name
  type            = each.value.type
  records         = [each.value.record]
  ttl             = 60
  allow_overwrite = true
}

resource "aws_acm_certificate_validation" "site" {
  provider                = aws.us_east_1
  certificate_arn         = aws_acm_certificate.site.arn
  validation_record_fqdns = [for record in aws_route53_record.cert_validation : record.fqdn]
}

module "site" {
  source = "../../"

  bucket_name         = "example-static-site-custom-domain"
  domain_aliases      = [var.domain_name]
  acm_certificate_arn = aws_acm_certificate_validation.site.certificate_arn

  tags = {
    project = "example-static-site"
  }
}

resource "aws_route53_record" "site" {
  zone_id = data.aws_route53_zone.site.zone_id
  name    = var.domain_name
  type    = "A"

  alias {
    name                   = module.site.distribution_domain_name
    zone_id                = "Z2FDTNDATAQYW2" # CloudFront's fixed hosted zone ID
    evaluate_target_health = false
  }
}

output "distribution_domain_name" {
  value = module.site.distribution_domain_name
}

output "site_url" {
  value = "https://${var.domain_name}"
}
