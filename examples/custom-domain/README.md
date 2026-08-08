# Custom domain example

Provisions the module with a custom domain: an ACM certificate is requested
and DNS-validated in an existing Route 53 hosted zone, then passed into the
module so CloudFront serves the site on that domain instead of the default
`*.cloudfront.net` one. An alias record is also created pointing the domain
at the distribution.

Since CloudFront only accepts certificates issued in `us-east-1`, the
certificate is created through an aliased `aws` provider even though the
rest of the stack can run in any region.

## Prerequisites

- A Route 53 hosted zone already exists for the domain you want to use.

## Run

```
terraform init
terraform plan -var="domain_name=www.example.com" -var="zone_name=example.com"
terraform apply -var="domain_name=www.example.com" -var="zone_name=example.com"
```

`bucket_name` in `main.tf` must be globally unique, so change it before
applying. Destroy when done:

```
terraform destroy -var="domain_name=www.example.com" -var="zone_name=example.com"
```
