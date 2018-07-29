terraform {
  required_version = ">= 0.10.3" # introduction of Local Values configuration language feature
}

#########
# data 
#########

data "aws_caller_identity" "current" {}

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
  security_groups      = ["${module.web_server_sg.this_security_group_id}"]
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

  load_balancer_name        = "${var.name}"
  security_groups           = ["${module.web_server_alb_sg.this_security_group_id}"]
  log_bucket_name           = "${aws_s3_bucket.alblogs.id}"
  subnets                   = "${var.subnet_ids_alb}"
  tags                      = "${var.tags}"
  vpc_id                    = "${var.vpc_id}"
  load_balancer_is_internal = "${var.load_balancer_is_internal}"

  https_listeners       = "${list(var.https_listeners)}"
  https_listeners_count = "${var.https_listeners_count}"

  http_tcp_listeners       = "${list(map("port", "80", "protocol", "HTTP"))}"
  http_tcp_listeners_count = "1"

  target_groups          = "${list(map("name", "ALB-${var.name}", "backend_protocol", "HTTP", "backend_port", "80"))}"
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

module "web_server_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "2.1.0"

  name        = "EC2-${var.name}"
  description = "Allow traffic from ALB-${var.name} with HTTP ports open within VPC"
  vpc_id      = "${var.vpc_id}"

  ingress_cidr_blocks = [
    "${module.web_server_alb_sg.this_security_group_id}",
    "${var.web_server_sg_ingress_cidr_blocks}",
  ]

  ingress_rules = ["${var.web_server_sg_ingress_rule}"]

  egress_cidr_blocks = ["${var.web_server_sg_egress_cidr_blocks}"]
  egress_rules       = ["${var.web_server_sg_egress_rule}"]

  tags = "${merge(var.tags, map("Name", "EC2-${var.name}"))}"
}

module "web_server_alb_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "2.1.0"

  name        = "ALB-${var.name}"
  description = "Allow traffic with HTTP and HTTPS ports from any."
  vpc_id      = "${var.vpc_id}"

  ingress_cidr_blocks = ["${var.web_server_alb_sg_ingress_cidr_blocks}"]
  ingress_rules       = ["${var.web_server_alb_sg_ingress_rule}"]

  tags = "${merge(var.tags, map("Name", "ALB-${var.name}"))}"
}

# The SG of Application Loadbalance
# resource "aws_security_group" "alb" {
#   name        = "ALB-${var.name}"
#   description = "Allow HTTP/HTTPS traffic from any."


#   vpc_id = "${var.vpc_id}"


#   ingress {
#     from_port   = 80
#     to_port     = 80
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }


#   ingress {
#     from_port   = 443
#     to_port     = 443
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }


#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }


#   tags = "${merge(var.tags, map("Name", "ALB-${var.name}"))}"
# }


# resource "aws_security_group" "asg" {
#   name        = "ASG-${var.name}"
#   description = "Allow 80 from ALB."


#   vpc_id = "${var.vpc_id}"


#   ingress {
#     from_port       = 80
#     to_port         = 80
#     protocol        = "tcp"
#     security_groups = ["${aws_security_group.alb.id}"]
#   }


#   tags = "${merge(var.tags, map("Name", "ASG-${var.name}"))}"
# }

