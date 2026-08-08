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

module "site" {
  source = "../../"

  bucket_name = "example-static-site"

  tags = {
    project = "example-static-site"
  }
}

output "bucket_id" {
  value = module.site.bucket_id
}

output "distribution_domain_name" {
  value = module.site.distribution_domain_name
}
