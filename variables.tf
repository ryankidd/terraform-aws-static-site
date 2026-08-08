variable "bucket_name" {
  description = "Name of the S3 bucket that stores the site content. Must be globally unique."
  type        = string
}

variable "tags" {
  description = "Tags applied to all resources created by this module."
  type        = map(string)
  default     = {}
}

variable "default_root_object" {
  description = "Object CloudFront returns for requests to the distribution root."
  type        = string
  default     = "index.html"
}

variable "price_class" {
  description = "CloudFront price class controlling which edge locations serve the distribution."
  type        = string
  default     = "PriceClass_100"

  validation {
    condition     = contains(["PriceClass_100", "PriceClass_200", "PriceClass_All"], var.price_class)
    error_message = "price_class must be one of PriceClass_100, PriceClass_200, or PriceClass_All."
  }
}

variable "domain_aliases" {
  description = "Custom domain names (CNAMEs) the distribution should respond to, e.g. [\"www.example.com\"]. Requires acm_certificate_arn to be set."
  type        = list(string)
  default     = []
}

variable "acm_certificate_arn" {
  description = "ARN of an existing ACM certificate covering domain_aliases. Must be issued in us-east-1, since CloudFront only accepts certificates from that region. Leave unset to use the default CloudFront certificate."
  type        = string
  default     = null
}
