####################
#  general variables
####################

variable "name" {
  description = "The name of project."
}

variable "env" {
  description = "The environment of project."
}

variable "tags" {
  description = "The tags of resource."
  type        = "map"
}

#############
# this module 
#############

variable "schedule_valid_time" {
  description = "A string of instance schedule valid time for Web."
  default     = ""
}

variable "schedule_valid_time_delay" {
  description = "A string of instance schedule valid time delay for Web."
  default     = "10m"
}

variable "travisci_enable" {
  description = "The travis-ci enable for Web."
  default     = false
}

variable "travisci_user_destroy" {
  description = "The travis-ci iam user destroy."
  default     = false
}

variable "iam_write_cloudwatch_log_enable" {
  description = "The IAM enable cloudwatch log for web."
  default     = false
}

variable "codedeploy_enable" {
  description = "The codedeploy enable for web."
  default     = false
}

variable "codedeploy_s3_destroy" {
  description = "A boolean of destroy s3 bucket for web."
  default     = true
}

variable "alblogs_s3_destroy" {
  description = "A boolean of destroy s3 bucket for ALB logs."
  default     = true
}

variable "web_ingress" {
  description = "A list of Security Group ingress for Web."
  default     = ["http-80-tcp"]
}

variable "alb_ingress" {
  description = "A list of Security Group ingress for ALB."
  default     = ["http-80-tcp", "https-443-tcp"]
}

variable "web_ingress_cidr_blocks" {
  description = "A list of Security Group ingress cidr for Web."
  default     = []
}

variable "web_ingress_source_security_group_id" {
  description = "A list of Security Group ingress other security group source id for Web."
  default     = []
}

variable "web_number_of_ingress_source_security_group_id" {
  description = "A string of Security Group ingress number other security group source id for Web."
  default     = "0"
}

variable "alb_ingress_cidr_blocks" {
  description = "A list of Security Group ingress cidr for ALB."
  default     = ["0.0.0.0/0"]
}

variable "web_ingress_ipv6_cidr_blocks" {
  description = "A list of Security Group ingress cidr for Web."
  default     = []
}

variable "alb_ingress_ipv6_cidr_blocks" {
  description = "A list of Security Group ingress cidr for ALB."
  default     = []
}

variable "web_ingress_prefix_list_ids" {
  description = "A list of Security Group ingress prefix list IDs for Web."
  default     = []
}

variable "alb_ingress_prefix_list_ids" {
  description = "A list of Security Group ingress prefix list IDs for ALB."
  default     = []
}

variable "codedeploy_deployment_config_name" {
  description = "A string of deployment config name for codedeploy."
  default     = "CodeDeployDefault.OneAtATime"
}

variable "codedeploy_deployment_style" {
  description = "A map of deployment style for codedeploy."
  type        = "map"

  default = {
    deployment_option = "WITH_TRAFFIC_CONTROL"
    deployment_type   = "IN_PLACE"
  }
}

variable "codedeploy_blue_green_deployment_config" {
  description = "A list of deployment config with blue / green for codedeploy."
  default     = []
}

variable "autoscaling_schedule_enable" {
  description = "A boolean of instance schedule enable for autoscaling."
  default     = false
}

variable "autoscaling_schedule" {
  description = "A list of instance schedule for autoscaling. default a 5x8 work week with online AM 08:00 and offline 20:00, saturday and sunday is holiday."
  type        = "list"
  default     = []

  # online days
  # {
  #   action_name      = "monday-online"
  #   min_size         = 0
  #   max_size         = 1
  #   desired_capacity = 1
  #   recurrence       = "0 8 * * 1"
  # },
  # {
  #   action_name      = "tuesday-online"
  #   min_size         = 0
  #   max_size         = 1
  #   desired_capacity = 1
  #   recurrence       = "0 8 * * 2"
  # },
  # {
  #   action_name      = "wednesday-online"
  #   min_size         = 0
  #   max_size         = 1
  #   desired_capacity = 1
  #   recurrence       = "0 8 * * 3"
  # },
  # {
  #   action_name      = "thursday-online"
  #   min_size         = 0
  #   max_size         = 1
  #   desired_capacity = 1
  #   recurrence       = "0 8 * * 4"
  # },
  # {
  #   action_name      = "friday-online"
  #   min_size         = 0
  #   max_size         = 1
  #   desired_capacity = 1
  #   recurrence       = "0 8 * * 5"
  # },
  # # offline days
  # {
  #   action_name      = "monday-offline"
  #   min_size         = 0
  #   max_size         = 0
  #   desired_capacity = 0
  #   recurrence       = "0 20 * * 1"
  # },
  # {
  #   action_name      = "tuesday-offline"
  #   min_size         = 0
  #   max_size         = 0
  #   desired_capacity = 0
  #   recurrence       = "0 20 * * 2"
  # },
  # {
  #   action_name      = "wednesday-offline"
  #   min_size         = 0
  #   max_size         = 0
  #   desired_capacity = 0
  #   recurrence       = "0 20 * * 3"
  # },
  # {
  #   action_name      = "thursday-offline"
  #   min_size         = 0
  #   max_size         = 0
  #   desired_capacity = 0
  #   recurrence       = "0 20 * * 4"
  # },
  # {
  #   action_name      = "friday-offline"
  #   min_size         = 0
  #   max_size         = 0
  #   desired_capacity = 0
  #   recurrence       = "0 20 * * 4"
  # }
}

#############
# ASG module 
#############
variable "vpc_id" {
  description = "The id of VPC."
}

variable "image_id" {
  description = "The AMI ID of launchconfig."
}

variable "instance_type" {
  description = "The instance_type of launchconfig."
  default     = "t2.micro"
}

variable "key_name" {
  description = "The key pair name of launchconfig."
}

variable "user_data" {
  description = "The user data of launchconfig."
  default     = " "
}

variable "ec2_subnet_ids" {
  description = "The ids of subnet for EC2."
  type        = "list"
}

variable "asg_min_size" {
  description = "ASG min instance count."
  default     = "1"
}

variable "asg_max_size" {
  description = "ASG max instance count."
  default     = "2"
}

variable "asg_desired_capacity" {
  description = "ASG desired_capacity instance count."
  default     = "1"
}

variable "asg_health_check_type" {
  description = "ASG health_check_type."
  default     = "EC2"
}

#############
# ALB module 
#############

# variable "load_balancer_internal_enable" {
#   description = "The internal access of ALB."
#   default     = false
# }

# variable "load_balancer_internal_enable" {
#   description = "The internal access of ALB."
#   default     = false
# }

variable "alb_https_listeners" {
  description = "A list of maps describing the HTTPS listeners for this ALB. Required key/values: port, certificate_arn. Optional key/values: ssl_policy."
  type        = "map"

  default = {
    certificate_arn = ""
    port            = "443"
    ssl_policy      = "ELBSecurityPolicy-TLS-1-2-2017-01"
  }
}

variable "alb_https_listeners_count" {
  description = "A manually provided count/length of the https_listeners list of maps since the list cannot be computed.."
  default     = "0"
}

variable "alb_subnet_ids" {
  description = "The ids of subnet for ALB."
  type        = "list"
}

variable "load_balancer_is_internal" {
  description = "Boolean determining if the load balancer is internal or externally facing."
  default     = false
}

variable "alb_target_groups_defaults" {
  description = "Default values for target groups as defined by the list of maps."
  type        = "map"

  default = {
    "cookie_duration"                  = 86400
    "deregistration_delay"             = 300
    "health_check_interval"            = 5
    "health_check_healthy_threshold"   = 2
    "health_check_path"                = "/"
    "health_check_port"                = "traffic-port"
    "health_check_timeout"             = 4
    "health_check_unhealthy_threshold" = 2
    "health_check_matcher"             = "200"
    "stickiness_enabled"               = false
    "target_type"                      = "instance"
  }
}
