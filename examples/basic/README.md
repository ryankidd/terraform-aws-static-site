# Basic example

Provisions the module with its defaults: a private S3 bucket served through
CloudFront over the default `*.cloudfront.net` domain, no custom domain or
ACM certificate.

## Run

```
terraform init
terraform plan
terraform apply
```

`bucket_name` must be globally unique, so change it in `main.tf` before
applying. Destroy when done:

```
terraform destroy
```
