###########
# IAM User
###########

# IAM User for Travis CI
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

###########
# IAM Role
###########

# Role for EC2
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

resource "aws_iam_role_policy_attachment" "ec2_web_codedeploy_s3" {
  count = "${var.codedeploy_enable ? 1 : 0}"

  role       = "${aws_iam_role.ec2_web.name}"
  policy_arn = "${aws_iam_policy.ec2-to-s3-for-codedeploy.arn}"
}

resource "aws_iam_instance_profile" "ec2_web_instance_profile" {
  name = "${aws_iam_role.ec2_web.name}"
  role = "${aws_iam_role.ec2_web.name}"
}

# Role for Codedeploy
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
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ReadOnlyAccess"
}

##############
# IAM Policy
##############

# Policy for Travis CI
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

# Policy for ec2-to-s3-for-codedeploy
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

#################
# IAM Access Key
#################

# resource "aws_iam_access_key" "travisci_access_key" {
#   count = "${var.travisci_enable ? 1 : 0}"

#   user    = "${aws_iam_user.travisci_web.name}"
#   pgp_key = "keybase:some_person_that_exists"
# }