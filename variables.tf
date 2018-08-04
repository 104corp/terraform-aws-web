####################
#  general variables
####################

variable "name" {
  description = "The name of project."
}

variable "create" {
  description = "Whether to create security group and all rules"
  default     = false
}

variable "tags" {
  description = "The tags of resource."
  type        = "map"
}

#############
# this module 
#############

variable "travisci_enable" {
  description = "The travis-ci enable for autoscaling."
  default     = false
}

variable "travisci_user_destroy" {
  description = "The travis-ci iam user destroy."
  default     = false
}

variable "codedeploy_enable" {
  description = "The codedeploy enable for autoscaling."
  default     = false
}

variable "codedeploy_s3_destroy" {
  description = "The destroy of s3 bucket for codedeploy."
  default     = true
}

variable "alblogs_s3_destroy" {
  description = "The destroy of s3 bucket for ALB logs."
  default     = true
}

variable "web_ingress" {
  description = "The Security Group ingress of Web."
  default     = ["http-80-tcp"]
}

variable "alb_ingress" {
  description = "The Security Group ingress of ALB."
  default     = ["http-80-tcp", "https-443-tcp"]
}

variable "web_ingress_cidr_blocks" {
  description = "The Security Group ingress cidr of Web."
  default     = []
}

variable "web_ingress_source_security_group_id" {
  description = "The Security Group ingress other security group source id of Web."
  default     = []
}

variable "web_number_of_ingress_source_security_group_id" {
  description = "The Security Group ingress number other security group source id of Web."
  default     = "0"
}

variable "alb_ingress_cidr_blocks" {
  description = "The Security Group ingress cidr of ALB."
  default     = ["0.0.0.0/0"]
}

variable "web_ingress_ipv6_cidr_blocks" {
  description = "The Security Group ingress cidr of Web."
  default     = []
}

variable "alb_ingress_ipv6_cidr_blocks" {
  description = "The Security Group ingress cidr of ALB."
  default     = []
}

variable "web_ingress_prefix_list_ids" {
  description = "The Security Group ingress prefix list IDs of Web."
  default     = []
}

variable "alb_ingress_prefix_list_ids" {
  description = "The Security Group ingress prefix list IDs of ALB."
  default     = []
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

variable "subnet_ids_ec2" {
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
variable "https_listeners" {
  description = "A list of maps describing the HTTPS listeners for this ALB. Required key/values: port, certificate_arn. Optional key/values: ssl_policy."
  type        = "map"

  default = {
    certificate_arn = ""
    port            = "443"
    ssl_policy      = "ELBSecurityPolicy-TLS-1-2-2017-01"
  }
}

variable "https_listeners_count" {
  description = "A manually provided count/length of the https_listeners list of maps since the list cannot be computed.."
  default     = "0"
}

variable "subnet_ids_alb" {
  description = "The ids of subnet for ALB."
  type        = "list"
}

variable "load_balancer_is_internal" {
  description = "Boolean determining if the load balancer is internal or externally facing."
  default     = false
}

variable "target_groups_defaults" {
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
