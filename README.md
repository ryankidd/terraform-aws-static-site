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
is only readable through CloudFront. A managed response headers policy
adds baseline security headers by default. Custom domains and CloudFront
access logging are both supported and variable-gated. CI runs formatting,
validation, linting, and a Checkov security scan on every push.

## Usage

1. Add the module to your configuration, setting at least `bucket_name`
   (it must be globally unique):

   ```hcl
   module "site" {
     source = "github.com/ryankidd/terraform-aws-static-site"

     bucket_name = "my-static-site"
   }
   ```

2. Run `terraform init` and `terraform apply`.
3. Upload your site's files into the bucket (`module.site.bucket_id`), for
   example with `aws s3 sync ./dist s3://my-static-site`.
4. Serve the site from `module.site.distribution_domain_name`, or from
   a custom domain — see below.

Requests to paths without a file extension resolve to
`var.default_root_object` (`index.html` by default) only at the
distribution root; this module doesn't configure per-directory index
documents or a 404 rewrite, so a single-page app needs its own error
response handling in front of the distribution.

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

## Requirements

| Name | Version |
|---|---|
| terraform | >= 1.5 |
| aws | >= 5.0 |

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
