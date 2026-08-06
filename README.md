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
bucket (versioned, public access blocked). CloudFront distribution, custom
domain support, and CI are in progress.

## Inputs

| Name | Description | Type | Default |
|---|---|---|---|
| `bucket_name` | Name of the S3 bucket that stores the site content. Must be globally unique. | `string` | n/a |
| `tags` | Tags applied to all resources created by this module. | `map(string)` | `{}` |

## Outputs

| Name | Description |
|---|---|
| `bucket_id` | ID of the S3 bucket storing site content. |
| `bucket_arn` | ARN of the S3 bucket storing site content. |
