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
  security_groups      = ["${aws_security_group.asg.id}"]
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
  security_groups           = ["${aws_security_group.alb.id}"]
  log_bucket_name           = "${aws_s3_bucket.alblogs.id}"
  subnets                   = "${var.subnet_ids_alb}"
  tags                      = "${var.tags}"
  vpc_id                    = "${var.vpc_id}"
  load_balancer_is_internal = "${var.load_balancer_is_internal}"

  https_listeners       = "${list(var.https_listeners)}"
  https_listeners_count = "${var.https_listeners_count}"

  http_tcp_listeners       = "${list(map("port", "80", "protocol", "HTTP"))}"
  http_tcp_listeners_count = "1"

  target_groups       = "${list(map("name", "ALB-${var.name}", "backend_protocol", "HTTP", "backend_port", "80"))}"
  target_groups_count = "1"

  target_groups_defaults = "${var.target_groups_defaults}"
}

####################
# Codedeploy module
####################

##############
# IAM module
##############

# Policy : ec2-to-s3-for-codedeploy
data "template_file" "ec2-to-s3-for-codedeploy" {
  template = "${file("${path.module}/policies/ec2-to-s3-for-codedeploy.json")}"

  vars {
    s3_arn = "${aws_s3_bucket.codedeploy.arn}"
  }
}

resource "aws_iam_policy" "ec2-to-s3-for-codedeploy" {
  name_prefix = "ec2-to-s3-for-codedeploy-${var.name}-"
  description = "EC2 to S3 Bucket for Codedeploy ${var.name} access."

  policy = "${data.template_file.ec2-to-s3-for-codedeploy.rendered}"
}

########
# Roles
########

# EC2
resource "aws_iam_role" "ec2_web" {
  name = "EC2-${var.name}"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_instance_profile" "ec2_web_instance_profile" {
  name = "${aws_iam_role.ec2_web.name}"
  role = "${aws_iam_role.ec2_web.name}"
}

# Role : Codedeploy
resource "aws_iam_role" "role_codedeploy" {
  name = "Codedeploy"

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "",
            "Effect": "Allow",
            "Principal": {
                "Service": [
                    "codedeploy.amazonaws.com"
                ]
            },
            "Action": "sts:AssumeRole"
        }
    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "role_codedeploy" {
  role       = "${aws_iam_role.role_codedeploy.name}"
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ReadOnlyAccess"
}

######
# S3
######

resource "aws_s3_bucket" "codedeploy" {
  bucket        = "codedeploy-${var.name}"
  acl           = "private"
  force_destroy = "${var.codedeploy_s3_destroy}"

  tags = "${var.tags}"
}

# ALB logs with bucket policy

resource "aws_s3_bucket" "alblogs" {
  bucket_prefix = "alblogs-${var.name}-"
  acl           = "private"
  force_destroy = "${var.alblogs_s3_destroy}"

  tags = "${var.tags}"
}

resource "aws_s3_bucket_policy" "alblogs" {
  bucket = "${aws_s3_bucket.alblogs.id}"

  policy = <<POLICY
{
  "Id": "Policy1429136655940",
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "Stmt1429136633762",
      "Action": [
        "s3:PutObject"
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:s3:::${aws_s3_bucket.alblogs.id}/AWSLogs/${data.aws_caller_identity.current.account_id}/*",
      "Principal": {
        "AWS": [
          "582318560864"
        ]
      }
    }
  ]
}
POLICY
}

#---------------------------------------------------------------------------------------------------------------------
# CLOUDWATCH
#---------------------------------------------------------------------------------------------------------------------

###################
# SECURITY GROUPS
###################

# The SG of Application Loadbalance
resource "aws_security_group" "alb" {
  name        = "ALB-${var.name}"
  description = "Allow HTTP/HTTPS traffic from any."

  vpc_id = "${var.vpc_id}"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = "${merge(var.tags, map("Name", "ALB-${var.name}"))}"
}

resource "aws_security_group" "asg" {
  name        = "ASG-${var.name}"
  description = "Allow 80 from ALB."

  vpc_id = "${var.vpc_id}"

  ingress {
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = ["${aws_security_group.alb.id}"]
  }

  tags = "${merge(var.tags, map("Name", "ASG-${var.name}"))}"
}
