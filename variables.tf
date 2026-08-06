variable "bucket_name" {
  description = "Name of the S3 bucket that stores the site content. Must be globally unique."
  type        = string
}

variable "tags" {
  description = "Tags applied to all resources created by this module."
  type        = map(string)
  default     = {}
}
