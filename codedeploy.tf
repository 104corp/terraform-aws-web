#########################
# Codedeploy module
#########################

resource "aws_codedeploy_app" "web" {
  count = "${var.codedeploy_enable ? 1 : 0}"

  name = "${var.name}"
}

resource "aws_codedeploy_deployment_group" "web" {
  count = "${var.codedeploy_enable ? 1 : 0}"

  app_name              = "${aws_codedeploy_app.web.name}"
  deployment_group_name = "${var.env}"
  service_role_arn      = "${aws_iam_role.role_codedeploy.arn}"

  deployment_style = ["${var.codedeploy_deployment_style}"]

  load_balancer_info {
    target_group_info {
      name = "${module.alb.target_group_names[0]}"
    }
  }

  deployment_config_name = "${var.codedeploy_deployment_config_name}"
  autoscaling_groups     = ["${module.autoscaling.this_autoscaling_group_name}"]

  blue_green_deployment_config = "${var.codedeploy_blue_green_deployment_config}"
}
