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

  # Auto scaling group
  asg_name                  = "${var.name}"
  vpc_zone_identifier       = "${var.subnet_ids_ec2}"
  health_check_type         = "${var.asg_health_check_type}"
  min_size                  = "${var.asg_min_size}"
  max_size                  = "${var.asg_max_size}"
  desired_capacity          = "${var.asg_desired_capacity}"
  wait_for_capacity_timeout = 0
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
  subnets                   = "${var.subnet_ids_alb}"
  tags                      = "${var.tags}"
  vpc_id                    = "${var.vpc_id}"
  load_balancer_is_internal = "${var.load_balancer_is_internal}"

  https_listeners       = "${list(var.https_listeners)}"
  https_listeners_count = "${var.https_listeners_count}"

  http_tcp_listeners       = "${list(map("port", "80", "protocol", "HTTP"))}"
  http_tcp_listeners_count = "1"

  target_groups          = "${list(map("name", "ALB-TG-${var.name}", "backend_protocol", "HTTP", "backend_port", "80"))}"
  target_groups_count    = "1"
  target_groups_defaults = "${var.target_groups_defaults}"
}

####################
# Codedeploy module
####################

#---------------------------------------------------------------------------------------------------------------------
# CLOUDWATCH
#---------------------------------------------------------------------------------------------------------------------

#########################
# Security Groups module
#########################

resource "aws_security_group" "web_server_sg" {
  name_prefix = "EC2-${var.name}-"
  description = "Allow traffic from ALB-${var.name} with HTTP ports open within VPC"

  vpc_id      = "${var.vpc_id}"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = "${merge(var.tags, map("Name", "EC2-${var.name}"))}"
}

resource "aws_security_group" "web_server_alb_sg" {
  name_prefix = "ALB-${var.name}-"
  description = "Allow traffic with HTTP and HTTPS ports from any."
  vpc_id      = "${var.vpc_id}"

  lifecycle {
    create_before_destroy = true
  }

  tags = "${merge(var.tags, map("Name", "ALB-${var.name}"))}"
}

resource "aws_security_group_rule" "web_ingress_with_cidr_blocks" {
  count = "${length(var.web_ingress_cidr_blocks)}"

  security_group_id = "${aws_security_group.web_server_alb_sg.id}"
  type              = "ingress"

  cidr_blocks      = ["${var.web_ingress_cidr_blocks}"]
  ipv6_cidr_blocks = ["${var.web_ingress_ipv6_cidr_blocks}"]
  prefix_list_ids  = ["${var.web_ingress_prefix_list_ids}"]
  description      = "${element(var.rules[var.web_ingress[count.index]], 3)}"

  from_port = "${element(var.rules[var.web_ingress[count.index]], 0)}"
  to_port   = "${element(var.rules[var.web_ingress[count.index]], 1)}"
  protocol  = "${element(var.rules[var.web_ingress[count.index]], 2)}"
}

resource "aws_security_group_rule" "web_ingress_with_source_security_group_id" {
  count = "${length(var.web_ingress_source_security_group_id)}"

  security_group_id = "${aws_security_group.web_server_sg.id}"
  type              = "ingress"

  source_security_group_id = "${lookup(var.web_ingress_source_security_group_id[count.index], "source_security_group_id")}"

  ipv6_cidr_blocks  = ["${var.web_ingress_ipv6_cidr_blocks}"]
  prefix_list_ids   = ["${var.web_ingress_prefix_list_ids}"]
  description       = "${lookup(var.web_ingress_source_security_group_id[count.index], "description",element(var.rules[lookup(var.web_ingress_source_security_group_id[count.index], "rule", "_")], 3))}"

  from_port = "${lookup(var.web_ingress_source_security_group_id[count.index], "from_port", element(var.rules[lookup(var.web_ingress_source_security_group_id[count.index], "rule", "_")], 0))}"
  to_port   = "${lookup(var.web_ingress_source_security_group_id[count.index], "to_port", element(var.rules[lookup(var.web_ingress_source_security_group_id[count.index], "rule", "_")], 1))}"
  protocol  = "${lookup(var.web_ingress_source_security_group_id[count.index], "protocol", element(var.rules[lookup(var.web_ingress_source_security_group_id[count.index], "rule", "_")], 2))}"
}

resource "aws_security_group_rule" "alb_ingress_with_cidr_blocks" {
  count = "${length(var.alb_ingress)}"

  security_group_id = "${aws_security_group.web_server_alb_sg.id}"
  type              = "ingress"

  cidr_blocks      = ["${var.alb_ingress_cidr_blocks}"]
  ipv6_cidr_blocks = ["${var.alb_ingress_ipv6_cidr_blocks}"]
  prefix_list_ids  = ["${var.alb_ingress_prefix_list_ids}"]
  description      = "${element(var.rules[var.alb_ingress[count.index]], 3)}"

  from_port = "${element(var.rules[var.alb_ingress[count.index]], 0)}"
  to_port   = "${element(var.rules[var.alb_ingress[count.index]], 1)}"
  protocol  = "${element(var.rules[var.alb_ingress[count.index]], 2)}"
}

