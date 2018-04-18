#---------------------------------------------------------------------------------------------------------------------
# PROVIDER SETTING
#---------------------------------------------------------------------------------------------------------------------

provider "aws" {
  region  = "${var.aws_region}"
  profile = "${var.aws_profile}"
  version = "~> 1.14"
}

provider "template" {
  version = "~> 1.0"
}

#---------------------------------------------------------------------------------------------------------------------
# TAGS
#---------------------------------------------------------------------------------------------------------------------

locals {
  res_tag = "${map(
    "Project", "${var.project_name}",
    "Env", "${var.project_env}",
    "Managedby", "TERRAFORM"
  )}"
}

#---------------------------------------------------------------------------------------------------------------------
# AUTO SCALING GROUP
#---------------------------------------------------------------------------------------------------------------------

module "asg" {
  source  = "terraform-aws-modules/autoscaling/aws"
  version = "2.2.2"

  name        = "${var.project_name}"
  tags_as_map = "${local.res_tag}"

  # Launch configuration
  lc_name              = "${var.project_name}"
  image_id             = "${var.image_id}"
  instance_type        = "${var.instance_type}"
  security_groups      = ["${aws_security_group.asg.id}"]
  iam_instance_profile = "${aws_iam_instance_profile.role_ec2_instance_profile.arn}"
  target_group_arns    = "${module.alb.target_group_arns}"

  # Auto scaling group
  asg_name                  = "ASG-${var.project_name}-${var.project_env}-"
  vpc_zone_identifier       = "${var.subnet_ids_ec2}"
  health_check_type         = "${var.asg_health_check_type}"
  min_size                  = "${var.asg_min_size}"
  max_size                  = "${var.asg_max_size}"
  desired_capacity          = "${var.asg_desired_capacity}"
  wait_for_capacity_timeout = 0
}

#---------------------------------------------------------------------------------------------------------------------
# APPLICATION LOADBALANCE
#---------------------------------------------------------------------------------------------------------------------

module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "3.2.0"

  load_balancer_name        = "ALB-${var.project_name}-${var.project_env}"
  security_groups           = ["${aws_security_group.alb.id}"]
  log_bucket_name           = "${aws_s3_bucket.alblogs.id}"
  subnets                   = "${var.subnet_ids_alb}"
  tags                      = "${local.res_tag}"
  vpc_id                    = "${var.vpc_id}"
  load_balancer_is_internal = "${var.load_balancer_is_internal}"

  https_listeners       = "${list(var.https_listeners)}"
  https_listeners_count = "${var.https_listeners_count}"

  http_tcp_listeners       = "${list(map("port", "80", "protocol", "HTTP"))}"
  http_tcp_listeners_count = "1"

  target_groups       = "${list(map("name", "ALB-${var.project_name}-${var.project_env}", "backend_protocol", "HTTP", "backend_port", "80"))}"
  target_groups_count = "1"

  target_groups_defaults = "${var.target_groups_defaults}"
}

#---------------------------------------------------------------------------------------------------------------------
# CODEDEPLOY
#---------------------------------------------------------------------------------------------------------------------

#---------------------------------------------------------------------------------------------------------------------
# IAM
#---------------------------------------------------------------------------------------------------------------------

# Policis
#---------------------------------------------------------------------------------------------------------------------

# Policy : s3-codedeploy
data "template_file" "s3-codedeploy" {
  template = "${file("${path.module}/policies/s3-codedeploy.json")}"

  vars {
    s3_arn = "${aws_s3_bucket.codedeploy.arn}"
  }
}

resource "aws_iam_policy" "s3-codedeploy" {
  name_prefix = "s3-codedeploy-${var.project_name}-${var.project_env}-"
  description = "S3 Bucket s3-codedeploy-${var.project_name} access."

  policy = "${data.template_file.s3-codedeploy.rendered}"
}

# Policy : ssm
data "template_file" "ssm" {
  template = "${file("${path.module}/policies/ssm.json")}"

  vars {
    aws_accountid = "${var.aws_accountid}"
    project_name  = "${var.project_name}"
  }
}

resource "aws_iam_policy" "ssm" {
  name_prefix = "ssm-${var.project_name}-${var.project_env}-"
  description = "SSM paramatert store ${var.project_name}-${var.project_env}- access."

  policy = "${data.template_file.ssm.rendered}"
}

# Policy : cwl
data "template_file" "cwl" {
  template = "${file("${path.module}/policies/cwl.json")}"

  vars {
    aws_accountid = "${var.aws_accountid}"
    project_name  = "${var.project_name}"
  }
}

resource "aws_iam_policy" "cwl" {
  name_prefix = "cwlog-${var.project_name}-${var.project_env}-"
  description = "Cloudwatch ${var.project_name}-${var.project_env}- access."

  policy = "${data.template_file.cwl.rendered}"
}

# Roles
#---------------------------------------------------------------------------------------------------------------------

# Role : EC2
resource "aws_iam_role" "role_ec2" {
  name = "Role-EC2-${var.project_name}"

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

resource "aws_iam_instance_profile" "role_ec2_instance_profile" {
  name = "${aws_iam_role.role_ec2.name}"
  role = "${aws_iam_role.role_ec2.name}"
}

# Role : Codedeploy
resource "aws_iam_role" "role_codedeploy" {
  name = "Role-Codedeploy-${var.project_name}"

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

#---------------------------------------------------------------------------------------------------------------------
# S3
#---------------------------------------------------------------------------------------------------------------------

# Codedeploy
resource "aws_s3_bucket" "codedeploy" {
  bucket_prefix = "codedeploy-${var.project_name}-${var.project_env}-"
  acl           = "private"

  tags = "${local.res_tag}"
}

# ALB logs with bucket policy
resource "aws_s3_bucket" "alblogs" {
  bucket_prefix = "alblogs-${var.project_name}-${var.project_env}-"
  acl           = "private"

  tags = "${local.res_tag}"
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
      "Resource": "arn:aws:s3:::${aws_s3_bucket.alblogs.id}/AWSLogs/${var.aws_accountid}/*",
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
# SES
#---------------------------------------------------------------------------------------------------------------------
#---------------------------------------------------------------------------------------------------------------------
# CLOUDWATCH
#---------------------------------------------------------------------------------------------------------------------

#---------------------------------------------------------------------------------------------------------------------
# SECURITY GROUPS
#---------------------------------------------------------------------------------------------------------------------

# The SG of Application Loadbalance
resource "aws_security_group" "alb" {
  name   = "SG-ALB-${var.project_name}-${var.project_env}"
  vpc_id = "${var.vpc_id}"

  tags = "${merge(
    local.res_tag,
    map(
      "Name", "SG-ALB-${var.project_name}-${var.project_env}"
    )
  )}"

  description = "Allow HTTP/HTTPS traffic from any."

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
}

# The SG of AutoScalingGroup EC2 instance
resource "aws_security_group" "asg" {
  name        = "SG-ASG-${var.project_name}-${var.project_env}"
  vpc_id      = "${var.vpc_id}"
  description = "Allow HTTP from ALB and SSH from bastion."

  tags = "${merge(
    local.res_tag,
    map(
      "Name", "SG-ASG-${var.project_name}-${var.project_env}"
    )
  )}"

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = ["${aws_security_group.alb.id}"]
  }

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"

    #security_groups = "${var.sg_bastion_ids}"
    security_groups = ["${var.enable_bastion_ssh == "true" ?  var.sg_bastion_id : aws_security_group.alb.id }"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
