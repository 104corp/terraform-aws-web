###########################
# IAM User for Travis CI
###########################

resource "aws_iam_user" "travisci_web" {
  count = "${var.travisci_enable ? 1 : 0}"

  name = "travis-${var.name}"

  force_destroy = "${var.travisci_user_destroy}"
}

resource "aws_iam_user_policy_attachment" "travisci_codedeploy" {
  count = "${var.codedeploy_enable ? 1 : 0}"

  user       = "${aws_iam_user.travisci_web.name}"
  policy_arn = "arn:aws:iam::aws:policy/AWSCodeDeployDeployerAccess"
}

resource "aws_iam_user_policy" "travisci_to_s3" {
  count = "${var.travisci_enable && var.codedeploy_enable ? 1 : 0}"

  name = "travisci-to-s3-${var.name}"
  user = "${aws_iam_user.travisci_web.name}"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "Stmt1493702920000",
            "Effect": "Allow",
            "Action": [
                "s3:*"
            ],
            "Resource": [
                "${aws_s3_bucket.codedeploy.arn}/*"
            ]
        }
    ]
}
EOF
}

resource "aws_iam_access_key" "travisci_access_key" {
  count = "${var.travisci_enable ? 1 : 0}"

  user = "${aws_iam_user.travisci_web.name}"
}

###########################
# IAM Role for EC2 Web
###########################

# Role for EC2 Web
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

## If you need support CodeDeploy with S3
data "template_file" "ec2-to-s3-for-codedeploy" {
  count = "${var.codedeploy_enable ? 1 : 0}"

  template = "${file("${path.module}/policies/ec2-to-s3-for-codedeploy.json")}"

  vars {
    s3_arn = "${aws_s3_bucket.codedeploy.arn}"
  }
}

resource "aws_iam_policy" "ec2-to-s3-for-codedeploy" {
  count = "${var.codedeploy_enable ? 1 : 0}"

  name_prefix = "ec2-to-s3-for-codedeploy-${var.name}-"
  description = "EC2 to S3 Bucket for Codedeploy ${var.name} access."

  policy = "${data.template_file.ec2-to-s3-for-codedeploy.rendered}"
}

resource "aws_iam_role_policy_attachment" "ec2_web_codedeploy_s3" {
  count = "${var.codedeploy_enable ? 1 : 0}"

  role       = "${aws_iam_role.ec2_web.name}"
  policy_arn = "${aws_iam_policy.ec2-to-s3-for-codedeploy.arn}"
}

## If you need write to CloudWatch Log
data "template_file" "ec2_cloudwatch_write" {
  count = "${var.iam_write_cloudwatch_log_enable ? 1 : 0}"

  template = "${file("${path.module}/policies/cloudwatch_log_write.json")}"
}

resource "aws_iam_policy" "ec2_cloudwatch_log_write" {
  count = "${var.iam_write_cloudwatch_log_enable ? 1 : 0}"

  name_prefix = "cloudwatch_log_write-"
  description = "Permission to access CloudWatch Log"

  policy = "${data.template_file.ec2_cloudwatch_write.rendered}"
}

resource "aws_iam_role_policy_attachment" "ec2_write_cloudwatch_log" {
  count = "${var.iam_write_cloudwatch_log_enable ? 1 : 0}"

  role       = "${aws_iam_role.ec2_web.name}"
  policy_arn = "${aws_iam_policy.ec2_cloudwatch_log_write.arn}"
}

#################################
# Role for Codedeploy Service
#################################
resource "aws_iam_role" "role_codedeploy" {
  count = "${var.codedeploy_enable ? 1 : 0}"

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
  count = "${var.codedeploy_enable ? 1 : 0}"

  role       = "${aws_iam_role.role_codedeploy.name}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSCodeDeployRole"
}

#################
# IAM Access Key
#################

