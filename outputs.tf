### ASG
output "autoscaling_group_id" {
  description = "The ID of the Autoscaling"
  value       = "${module.autoscaling.this_autoscaling_group_id}"
}

output "autoscaling_group_id_arn" {
  description = "The ARN of the Autoscaling"
  value       = "${module.autoscaling.this_autoscaling_group_arn}"
}

output "autoscaling_group_name" {
  description = "The name of the Autoscaling"
  value       = "${module.autoscaling.this_autoscaling_group_name}"
}

output "autoscaling_group_default_cooldown" {
  description = "The default cooldown of the Autoscaling"
  value       = "${module.autoscaling.this_autoscaling_group_default_cooldown}"
}

output "autoscaling_group_desired_capacity" {
  description = "The desired capacity of the Autoscaling"
  value       = "${module.autoscaling.this_autoscaling_group_desired_capacity}"
}

output "autoscaling_group_health_check_grace_period" {
  description = "The health check grace period of the Autoscaling"
  value       = "${module.autoscaling.this_autoscaling_group_health_check_grace_period}"
}

output "autoscaling_group_health_check_type" {
  description = "The health check type of the Autoscaling"
  value       = "${module.autoscaling.this_autoscaling_group_health_check_type}"
}

output "autoscaling_group_min_size" {
  description = "The instance min size of the Autoscaling"
  value       = "${module.autoscaling.this_autoscaling_group_min_size}"
}

output "autoscaling_group_max_size" {
  description = "The instance max size of the Autoscaling"
  value       = "${module.autoscaling.this_autoscaling_group_max_size}"
}

### Launch Configuration
output "launch_configuration_id" {
  description = "The ID of the Launch configuration"
  value       = "${module.autoscaling.this_launch_configuration_id}"
}

output "launch_configuration_name" {
  description = "The name of the Launch configuration"
  value       = "${module.autoscaling.this_launch_configuration_name}"
}


### Codedeploy

## IAM

### Travis CI user
output "travisci_user_arn" {
  description = "The IAM user arn of Travis CI."
  value       = "${aws_iam_user.travisci_web.*.arn}"
}

output "travisci_user_name" {
  description = "The IAM user name of Travis CI."
  value       = "${aws_iam_user.travisci_web.*.name}"
}

output "travisci_user_unique_id" {
  description = "The IAM user unique id of Travis CI."
  value       = "${aws_iam_user.travisci_web.*.unique_id}"
}

### Web role

output "web_role_arn" {
  description = "A string of IAM Role arn for Web."
  value       = "${aws_iam_role.ec2_web.*.arn}"
}

output "web_role_name" {
  description = "A string of IAM Role name for Web."
  value       = "${aws_iam_role.ec2_web.*.name}"
}

output "web_role_unique_id" {
  description = "A string IAM Role unique id for Web."
  value       = "${aws_iam_role.ec2_web.*.unique_id}"
}

### Codedeploy role

output "codedeploy_role_arn" {
  description = "A string of IAM Role arn for codedeploy."
  value       = "${aws_iam_role.role_codedeploy.*.arn}"
}

output "codedeploy_role_name" {
  description = "A string of IAM Role name for codedeploy."
  value       = "${aws_iam_role.role_codedeploy.*.name}"
}

output "codedeploy_role_unique_id" {
  description = "A string IAM Role unique id for codedeploy."
  value       = "${aws_iam_role.role_codedeploy.*.unique_id}"
}

### Security Groups
output "web_sg_id" {
  description = "The Security Group ID of Web."
  value       = "${aws_security_group.web_server_sg.id}"
}

output "alb_sg_id" {
  description = "The Security Group ID of ALB."
  value       = "${aws_security_group.web_server_alb_sg.id}"
}
