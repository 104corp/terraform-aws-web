config {
  terraform_version = "0.10.3"

  ignore_module = {
    "terraform-aws-modules/autoscaling/aws" = true
    "terraform-aws-modules/alb/aws" = true
  }
}
