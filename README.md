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
is only readable through CloudFront. Custom domain support and CI are in
progress.

## Inputs

| Name | Description | Type | Default |
|---|---|---|---|
| `bucket_name` | Name of the S3 bucket that stores the site content. Must be globally unique. | `string` | n/a |
| `tags` | Tags applied to all resources created by this module. | `map(string)` | `{}` |
| `default_root_object` | Object CloudFront returns for requests to the distribution root. | `string` | `"index.html"` |
| `price_class` | CloudFront price class controlling which edge locations serve the distribution. | `string` | `"PriceClass_100"` |

## Outputs

| Name | Description |
|---|---|
| `bucket_id` | ID of the S3 bucket storing site content. |
| `bucket_arn` | ARN of the S3 bucket storing site content. |
| `distribution_id` | ID of the CloudFront distribution. |
| `distribution_domain_name` | Domain name of the CloudFront distribution. |
