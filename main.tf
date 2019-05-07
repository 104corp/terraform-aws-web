/**
  * # AWS Web Terraform module
  * 
  * ![Build Status](https://travis-ci.com/104corp/terraform-aws-web.svg?branch=master) ![LicenseBadge](https://img.shields.io/github/license/104corp/terraform-aws-web.svg)
  * 
  * Terraform module which creates web resources on AWS.
  * 
  * These types of resources are supported:
  * 
  * * [Autoscaling](https://www.terraform.io/docs/providers/aws/d/autoscaling_groups.html)
  * * [EC2](https://www.terraform.io/docs/providers/aws/r/instance.html)
  * * [ALB](https://www.terraform.io/docs/providers/aws/r/lb.html)
  * * [IAM role](https://www.terraform.io/docs/providers/aws/d/iam_role.html)
  * * [IAM policy](https://www.terraform.io/docs/providers/aws/r/iam_policy.html)
  * * [S3](https://www.terraform.io/docs/providers/aws/d/s3_bucket.html)
  * * [Security Group](https://www.terraform.io/docs/providers/aws/d/security_group.html)
  * 
  * ## Dependency
  * 
  * This module dependency of list:
  * 
  * * [autoscaling](https://registry.terraform.io/modules/terraform-aws-modules/autoscaling/aws/)
  * * [alb](https://registry.terraform.io/modules/terraform-aws-modules/alb/aws/)
  * 
  * ## Usage
  * 
  * ```hcl
  * module "web" {
  *   source = "104corp/web/aws"
  * 
  * }
  * ```
  * 
  * ## Terraform version
  * 
  * Terraform version 0.10.3 or newer is required for this module to work.
  * 
  * ## Examples
  * 
  * * [Simple web](https://github.com/104corp/terraform-aws-web/tree/master/examples/simple-web)
  * * [Complete web](https://github.com/104corp/terraform-aws-web/tree/master/examples/complete-web)
  * * [Manage Default web](https://github.com/104corp/terraform-aws-web/tree/master/examples/manage-default-web)
  *
  * ## Tests
  * 
  * This module has been packaged with [awspec](https://github.com/k1LoW/awspec) tests through test kitchen. To run them:
  * 
  * 1. Install [rvm](https://rvm.io/rvm/install) and the ruby version specified in the [Gemfile](https://github.com/104corp/terraform-aws-web/blob/master/Gemfile).
  * 2. Install bundler and the gems from our Gemfile:
  * ```
  * gem install bundler; bundle install
  * ```
  * 3. Test using `bundle exec kitchen test` from the root of the repo.
  * 
  * ## Authors
  * 
  * Module is maintained by [104corp](https://github.com/104corp).
  * 
  * ## License
  * 
  * Apache 2 Licensed. See LICENSE for full details.
  * 
*/

terraform {
  required_version = ">= 0.10.3" # introduction of Local Values configuration language feature
}

#########
# data 
#########

data "aws_caller_identity" "current" {}
data "aws_elb_service_account" "main" {}

#####################
# Autoscaling module
#####################

module "autoscaling" {
  source  = "terraform-aws-modules/autoscaling/aws"
  version = "2.7.0"

  name        = "${var.name}"
  tags_as_map = "${var.tags}"

  # Launch configuration
  lc_name              = "${var.name}"
  image_id             = "${var.image_id}"
  instance_type        = "${var.instance_type}"
  security_groups      = ["${aws_security_group.web_server_sg.id}"]
  iam_instance_profile = "${aws_iam_instance_profile.ec2_web_instance_profile.arn}"
  target_group_arns    = "${module.alb.target_group_arns}"
  key_name             = "${var.key_name}"
  user_data            = "${var.user_data}"

  # Auto scaling group
  asg_name                  = "${var.name}"
  vpc_zone_identifier       = "${var.ec2_subnet_ids}"
  health_check_type         = "${var.asg_health_check_type}"
  min_size                  = "${var.asg_min_size}"
  max_size                  = "${var.asg_max_size}"
  desired_capacity          = "${var.asg_desired_capacity}"
  wait_for_capacity_timeout = 0
}

resource "random_integer" "leading_time" {
  min = 1
  max = 100
}

locals {
  schedule_start_time = "${var.schedule_valid_time != "" ? var.schedule_valid_time : timeadd(timestamp(), var.schedule_valid_time_delay)}"
}

resource "aws_autoscaling_schedule" "web" {
  count = "${var.autoscaling_schedule_enable ? length(var.autoscaling_schedule) : 0}"

  scheduled_action_name  = "${lookup(var.autoscaling_schedule[count.index], "action_name", "")}"
  min_size               = "${lookup(var.autoscaling_schedule[count.index], "min_size", 0)}"
  max_size               = "${lookup(var.autoscaling_schedule[count.index], "max_size", 0)}"
  desired_capacity       = "${lookup(var.autoscaling_schedule[count.index], "desired_capacity", 0)}"
  start_time             = "${lookup(var.autoscaling_schedule[count.index], "start_time", "${local.schedule_start_time}")}"
  end_time               = "${lookup(var.autoscaling_schedule[count.index], "end_time", "3000-08-08T00:00:00Z")}"
  recurrence             = "${lookup(var.autoscaling_schedule[count.index], "recurrence", "")}"
  autoscaling_group_name = "${module.autoscaling.this_autoscaling_group_name}"
}

#########################
# ALB module
#########################

module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "3.4.0"

  load_balancer_name        = "ALB-${var.name}"
  security_groups           = ["${aws_security_group.web_server_alb_sg.id}"]
  log_bucket_name           = "${aws_s3_bucket.alblogs.id}"
  subnets                   = "${var.alb_subnet_ids}"
  tags                      = "${var.tags}"
  vpc_id                    = "${var.vpc_id}"
  load_balancer_is_internal = "${var.load_balancer_is_internal}"

  https_listeners       = "${list(var.alb_https_listeners)}"
  https_listeners_count = "${var.alb_https_listeners_count}"

  http_tcp_listeners       = "${list(map("port", "80", "protocol", "HTTP"))}"
  http_tcp_listeners_count = "1"

  target_groups          = "${list(map("name", "ALB-TG-${var.name}", "backend_protocol", "HTTP", "backend_port", "80"))}"
  target_groups_count    = "1"
  target_groups_defaults = "${var.alb_target_groups_defaults}"
}
