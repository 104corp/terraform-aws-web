####################
#  general variables
#####################

variable "name" {
  description = "The name of project."
}

variable "tags" {
  description = "The tags of resource."
  type        = "map"
}

#############
# this module 
#############

variable "codedeploy_s3_destroy" {
  description = "The destroy of s3 bucket for codedeploy."
  default     = false
}

variable "alblogs_s3_destroy" {
  description = "The destroy of s3 bucket for ALB logs."
  default     = false
}

variable "web_server_sg_ingress_cidr_blocks" {
  description = "The Security Group ingress CIDR blocks of ALB"
  default     = []
}

variable "web_server_sg_egress_cidr_blocks" {
  description = "The Security Group egress CIDR blocks of ALB"
  default     = ["0.0.0.0/0"]
}

variable "web_server_sg_egress_rule" {
  description = "The Security Group egress CIDR blocks of ALB"
  default     = ["all-all"]
}

variable "web_server_sg_ingress_rule" {
  description = "The Security Group rule ingress of web server"
  default     = ["http-80-tcp"]
}

variable "web_server_alb_sg_ingress_cidr_blocks" {
  description = "The Security Group ingress CIDR blocks of ALB"
  default     = ["0.0.0.0/0"]
}

variable "web_server_alb_sg_ingress_rule" {
  description = "The Security Group ingress CIDR blocks of ALB"
  default     = ["all-all"]
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
