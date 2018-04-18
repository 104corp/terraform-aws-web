#---------------------------------------------------------------------------------------------------------------------
# Default variables
#---------------------------------------------------------------------------------------------------------------------
# Module ASG
variable "instance_type" {
  description = "The instance_type of launchconfig."
  default     = "t2.micro"
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

# Module ALB
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

# Enable/Disable Bastion 
variable "sg_bastion_id" {
  description = "The Security Group id of bastion server, shoould be use with enable_bastion = true"
  default     = "sg-6ffcce09"
}

variable "enable_bastion_ssh" {
  description = "The Security Group id of bastion server"
  default     = true
}

#---------------------------------------------------------------------------------------------------------------------
# Required variables
#---------------------------------------------------------------------------------------------------------------------
variable "aws_accountid" {
  description = "AWS account id.(dev16 : 998121724123, stg16 : 766061410305, sys16 : 101414171737)"
}

variable "project_name" {
  description = "The name of project."
}

variable "project_env" {
  description = "The env of project EX: dev/staging/production."
}

variable "image_id" {
  description = "The AMI ID of launchconfig."
}

variable "vpc_id" {
  description = "The id of VPC."
}

variable "subnet_ids_ec2" {
  description = "The ids of subnet for EC2."
  type        = "list"
}

variable "subnet_ids_alb" {
  description = "The ids of subnet for ALB."
  type        = "list"
}
