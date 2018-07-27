### ASG
output "autoscaling_group_id" {
  description = "The ID of the Autoscaling"
  value       = "${module.autoscaling.this_autoscaling_group_id}"
}

output "autoscaling_group_id_arn" {
  description = "The ARN of the Autoscaling"
  value       = "${module.autoscaling.this_autoscaling_group_arn}"
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

output "autoscaling_group_name" {
  description = "The name of the Autoscaling"
  value       = "${module.autoscaling.this_autoscaling_group_name}"
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

### ALB

