# AWS Web Terraform module

![Build Status](https://travis-ci.com/104corp/terraform-aws-web.svg?branch=master) ![LicenseBadge](https://img.shields.io/github/license/104corp/terraform-aws-web.svg)

Terraform module which creates web resources on AWS.

These types of resources are supported:

* [Autoscaling](https://www.terraform.io/docs/providers/aws/d/autoscaling_groups.html)
* [EC2](https://www.terraform.io/docs/providers/aws/r/instance.html)
* [ALB](https://www.terraform.io/docs/providers/aws/r/lb.html)
* [IAM role](https://www.terraform.io/docs/providers/aws/d/iam_role.html)
* [IAM policy](https://www.terraform.io/docs/providers/aws/r/iam_policy.html)
* [S3](https://www.terraform.io/docs/providers/aws/d/s3_bucket.html)
* [Security Group](https://www.terraform.io/docs/providers/aws/d/security_group.html)

## Dependency

This module dependency of list:

* [aws-autoscaling](https://registry.terraform.io/modules/terraform-aws-modules/autoscaling/aws/)
* [aws-alb](https://registry.terraform.io/modules/terraform-aws-modules/alb/aws/)
* [aws-security-group](https://registry.terraform.io/modules/terraform-aws-modules/security-group/aws/)

## Usage

```hcl
module "web" {
  source = "104corp/web/aws"

}
```

## Terraform version

Terraform version 0.10.3 or newer is required for this module to work.

## Examples

* [Simple web](https://github.com/104corp/terraform-aws-web/tree/master/examples/simple-web)
* [Complete web](https://github.com/104corp/terraform-aws-web/tree/master/examples/complete-web)
* [Manage Default web](https://github.com/104corp/terraform-aws-web/tree/master/examples/manage-default-web)

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|

## Outputs

| Name | Description |
|------|-------------|


<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## Tests

This module has been packaged with [awspec](https://github.com/k1LoW/awspec) tests through test kitchen. To run them:

1. Install [rvm](https://rvm.io/rvm/install) and the ruby version specified in the [Gemfile](https://github.com/104corp/terraform-aws-web/blob/master/Gemfile).
2. Install bundler and the gems from our Gemfile:
```
gem install bundler; bundle install
```
3. Test using `bundle exec kitchen test` from the root of the repo.


## Authors

Module is maintained by [104corp](https://github.com/104corp).

basic fork of [Anton Babenko](https://github.com/antonbabenko)

## License

Apache 2 Licensed. See LICENSE for full details.

