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

* [autoscaling](https://registry.terraform.io/modules/terraform-aws-modules/autoscaling/aws/)
* [alb](https://registry.terraform.io/modules/terraform-aws-modules/alb/aws/)

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

## License

Apache 2 Licensed. See LICENSE for full details.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| alb\_https\_listeners | A list of maps describing the HTTPS listeners for this ALB. Required key/values: port, certificate_arn. Optional key/values: ssl_policy. | map | `<map>` | no |
| alb\_https\_listeners\_count | A manually provided count/length of the https_listeners list of maps since the list cannot be computed.. | string | `"0"` | no |
| alb\_ingress | A list of Security Group ingress for ALB. | list | `<list>` | no |
| alb\_ingress\_cidr\_blocks | A list of Security Group ingress cidr for ALB. | list | `<list>` | no |
| alb\_ingress\_ipv6\_cidr\_blocks | A list of Security Group ingress cidr for ALB. | list | `<list>` | no |
| alb\_ingress\_prefix\_list\_ids | A list of Security Group ingress prefix list IDs for ALB. | list | `<list>` | no |
| alb\_subnet\_ids | The ids of subnet for ALB. | list | n/a | yes |
| alb\_target\_groups\_defaults | Default values for target groups as defined by the list of maps. | map | `<map>` | no |
| alblogs\_s3\_destroy | A boolean of destroy s3 bucket for ALB logs. | string | `"true"` | no |
| asg\_desired\_capacity | ASG desired_capacity instance count. | string | `"1"` | no |
| asg\_health\_check\_type | ASG health_check_type. | string | `"EC2"` | no |
| asg\_max\_size | ASG max instance count. | string | `"2"` | no |
| asg\_min\_size | ASG min instance count. | string | `"1"` | no |
| auto\_groups | Map of groups of security group rules to use to generate modules (see update_groups.sh) | map | `<map>` | no |
| autoscaling\_schedule | A list of instance schedule for autoscaling. default a 5x8 work week with online AM 08:00 and offline 20:00, saturday and sunday is holiday. | list | `<list>` | no |
| autoscaling\_schedule\_enable | A boolean of instance schedule enable for autoscaling. | string | `"false"` | no |
| codedeploy\_blue\_green\_deployment\_config | A list of deployment config with blue / green for codedeploy. | list | `<list>` | no |
| codedeploy\_deployment\_config\_name | A string of deployment config name for codedeploy. | string | `"CodeDeployDefault.OneAtATime"` | no |
| codedeploy\_deployment\_style | A map of deployment style for codedeploy. | map | `<map>` | no |
| codedeploy\_enable | The codedeploy enable for autoscaling. | string | `"false"` | no |
| codedeploy\_s3\_destroy | A boolean of destroy s3 bucket for codedeploy. | string | `"true"` | no |
| ec2\_subnet\_ids | The ids of subnet for EC2. | list | n/a | yes |
| env | The environment of project. | string | n/a | yes |
| image\_id | The AMI ID of launchconfig. | string | n/a | yes |
| instance\_type | The instance_type of launchconfig. | string | `"t2.micro"` | no |
| key\_name | The key pair name of launchconfig. | string | n/a | yes |
| load\_balancer\_is\_internal | Boolean determining if the load balancer is internal or externally facing. | string | `"false"` | no |
| name | The name of project. | string | n/a | yes |
| rules | Map of known security group rules (define as 'name' = ['from port', 'to port', 'protocol', 'description']) | map | `<map>` | no |
| schedule\_valid\_time | A string of instance schedule valid time for Web. | string | `""` | no |
| schedule\_valid\_time\_delay | A string of instance schedule valid time delay for Web. | string | `"10m"` | no |
| tags | The tags of resource. | map | n/a | yes |
| travisci\_enable | The travis-ci enable for autoscaling. | string | `"false"` | no |
| travisci\_user\_destroy | The travis-ci iam user destroy. | string | `"false"` | no |
| user\_data | The user data of launchconfig. | string | n/a | yes |
| vpc\_id | The id of VPC. | string | n/a | yes |
| web\_ingress | A list of Security Group ingress for Web. | list | `<list>` | no |
| web\_ingress\_cidr\_blocks | A list of Security Group ingress cidr for Web. | list | `<list>` | no |
| web\_ingress\_ipv6\_cidr\_blocks | A list of Security Group ingress cidr for Web. | list | `<list>` | no |
| web\_ingress\_prefix\_list\_ids | A list of Security Group ingress prefix list IDs for Web. | list | `<list>` | no |
| web\_ingress\_source\_security\_group\_id | A list of Security Group ingress other security group source id for Web. | list | `<list>` | no |
| web\_number\_of\_ingress\_source\_security\_group\_id | A string of Security Group ingress number other security group source id for Web. | string | `"0"` | no |

## Outputs

| Name | Description |
|------|-------------|
| alb\_sg\_id | The Security Group ID of ALB. |
| autoscaling\_group\_default\_cooldown | The default cooldown of the Autoscaling |
| autoscaling\_group\_desired\_capacity | The desired capacity of the Autoscaling |
| autoscaling\_group\_health\_check\_grace\_period | The health check grace period of the Autoscaling |
| autoscaling\_group\_health\_check\_type | The health check type of the Autoscaling |
| autoscaling\_group\_id | The ID of the Autoscaling |
| autoscaling\_group\_id\_arn | The ARN of the Autoscaling |
| autoscaling\_group\_max\_size | The instance max size of the Autoscaling |
| autoscaling\_group\_min\_size | The instance min size of the Autoscaling |
| autoscaling\_group\_name | The name of the Autoscaling |
| codedeploy\_role\_arn | A string of IAM Role arn for codedeploy. |
| codedeploy\_role\_name | A string of IAM Role name for codedeploy. |
| codedeploy\_role\_unique\_id | A string IAM Role unique id for codedeploy. |
| launch\_configuration\_id | The ID of the Launch configuration |
| launch\_configuration\_name | The name of the Launch configuration |
| travisci\_user\_arn | The IAM user arn of Travis CI. |
| travisci\_user\_name | The IAM user name of Travis CI. |
| travisci\_user\_unique\_id | The IAM user unique id of Travis CI. |
| web\_role\_arn | A string of IAM Role arn for Web. |
| web\_role\_name | A string of IAM Role name for Web. |
| web\_role\_unique\_id | A string IAM Role unique id for Web. |
| web\_sg\_id | The Security Group ID of Web. |

