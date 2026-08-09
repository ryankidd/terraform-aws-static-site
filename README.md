# terraform-aws-static-site

A Terraform module for hosting a static site on AWS: S3 for content storage,
fronted by CloudFront.

```hcl
module "site" {
  source = "github.com/ryankidd/terraform-aws-static-site"

  bucket_name = "my-static-site"
  tags = {
    project = "my-static-site"
  }
}
```

## Status

Early and under active development. Currently provisions a private S3
bucket (versioned, public access blocked) fronted by a CloudFront
distribution using Origin Access Control, so the bucket stays private and
is only readable through CloudFront. Custom domains are supported by
passing an existing ACM certificate; CI is in progress.

### Custom domain

CloudFront only accepts ACM certificates issued in `us-east-1`, so this
module expects the certificate to already exist (create it with a provider
alias in the calling configuration) rather than provisioning one itself:

```hcl
module "site" {
  source = "github.com/ryankidd/terraform-aws-static-site"

  bucket_name          = "my-static-site"
  domain_aliases       = ["www.example.com"]
  acm_certificate_arn  = aws_acm_certificate.site.arn # must be in us-east-1
}
```

### Access logging

Set `enable_logging = true` to create a dedicated S3 bucket for CloudFront
access logs and turn on delivery to it. Logs land under the `cloudfront/`
prefix and expire automatically after 90 days. It's off by default so the
module doesn't provision an extra bucket for consumers who don't want one:

```hcl
module "site" {
  source = "github.com/ryankidd/terraform-aws-static-site"

  bucket_name    = "my-static-site"
  enable_logging = true
}
```

See [`examples/`](examples) for complete, runnable configurations.

## Inputs

| Name | Description | Type | Default |
|---|---|---|---|
| `bucket_name` | Name of the S3 bucket that stores the site content. Must be globally unique. | `string` | n/a |
| `tags` | Tags applied to all resources created by this module. | `map(string)` | `{}` |
| `default_root_object` | Object CloudFront returns for requests to the distribution root. | `string` | `"index.html"` |
| `price_class` | CloudFront price class controlling which edge locations serve the distribution. | `string` | `"PriceClass_100"` |
| `domain_aliases` | Custom domain names (CNAMEs) the distribution should respond to. Requires `acm_certificate_arn`. | `list(string)` | `[]` |
| `acm_certificate_arn` | ARN of an existing ACM certificate covering `domain_aliases`, issued in `us-east-1`. | `string` | `null` |
| `enable_logging` | Whether to create an S3 bucket for CloudFront access logs and enable logging on the distribution. | `bool` | `false` |

## Outputs

| Name | Description |
|---|---|
| `bucket_id` | ID of the S3 bucket storing site content. |
| `bucket_arn` | ARN of the S3 bucket storing site content. |
| `distribution_id` | ID of the CloudFront distribution. |
| `distribution_domain_name` | Domain name of the CloudFront distribution. |
| `logs_bucket_id` | ID of the S3 bucket storing CloudFront access logs, if `enable_logging` is true. |
