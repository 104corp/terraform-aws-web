
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| asg_desired_capacity | ASG desired_capacity instance count. | string | `1` | no |
| asg_health_check_type | ASG health_check_type. | string | `EC2` | no |
| asg_max_size | ASG max instance count. | string | `2` | no |
| asg_min_size | ASG min instance count. | string | `1` | no |
| aws_region | AWS region. | string | `ap-northeast-1` | no |
| image_id | The AMI ID of launchconfig. | string | - | yes |
| instance_type | The instance_type of launchconfig. | string | `t2.micro` | no |
| project_name | The name of project. | string | - | yes |
| project_phase | The phase of project EX: dev/staging/production. | string | - | yes |
| subnet_ids_alb | The ids of subnets for ALB. | list | - | yes |
| subnet_ids_ec2 | The ids of subnets for EC2. | list | - | yes |
| vpc_id | The id of VPC. | string | - | yes |

