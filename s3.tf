######
# S3
######

# bucket for Codedeploy source code.
resource "aws_s3_bucket" "codedeploy" {
  bucket        = "codedeploy-deployment-${var.name}"
  acl           = "private"
  force_destroy = "${var.codedeploy_s3_destroy}"

  tags = "${var.tags}"
}

# bucket with policy for ALB logs
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
          "${data.aws_elb_service_account.main.arn}"
        ]
      }
    }
  ]
}
POLICY
}
