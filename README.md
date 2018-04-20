## Simple web env

* ASG
* ALB
* SG
* CodeDeploy

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| asg_desired_capacity | ASG desired_capacity instance count. | string | `1` | no |
| asg_health_check_type | ASG health_check_type. | string | `EC2` | no |
| asg_max_size | ASG max instance count. | string | `2` | no |
| asg_min_size | ASG min instance count. | string | `1` | no |
| aws_accountid | AWS account id.(dev16 : 998121724123, stg16 : 766061410305, sys16 : 101414171737) | string | - | yes |
| enable_bastion_ssh | The Security Group id of bastion server | string | `true` | no |
| https_listeners | A list of maps describing the HTTPS listeners for this ALB. Required key/values: port, certificate_arn. Optional key/values: ssl_policy. | map | `<map>` | no |
| https_listeners_count | A manually provided count/length of the https_listeners list of maps since the list cannot be computed.. | string | `0` | no |
| image_id | The AMI ID of launchconfig. | string | - | yes |
| instance_type | The instance_type of launchconfig. | string | `t2.micro` | no |
| load_balancer_is_internal | Boolean determining if the load balancer is internal or externally facing. | string | `false` | no |
| project_env | The env of project EX: dev/staging/production. | string | - | yes |
| project_name | The name of project. | string | - | yes |
| sg_bastion_id | The Security Group id of bastion server, shoould be use with enable_bastion = true | string | `sg-6ffcce09` | no |
| subnet_ids_alb | The ids of subnet for ALB. | list | - | yes |
| subnet_ids_ec2 | The ids of subnet for EC2. | list | - | yes |
| target_groups_defaults | Default values for target groups as defined by the list of maps. | map | `<map>` | no |
| vpc_id | The id of VPC. | string | - | yes |




## Example

```
provider "aws" {
  profile = ""
  region  = "ap-northeast-1"
}


module "simpleweb" {
  source  = "app.terraform.io/104corp/simpleweb/aws"
  version = "0.1"

  image_id       = "ami-cece66a8"
  project_name   = "asmweb"
  project_env    = "dev"
  subnet_ids_alb = ["subnet-efb715a6", "subnet-7a987d21"]
  subnet_ids_ec2 = ["subnet-e29c79b9", "subnet-74ba183d"]
  vpc_id         = "vpc-7cf7ff18"
  aws_accountid  = "998121724123"
}

```
