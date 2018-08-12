#########################
# Security Groups module
#########################
resource "aws_security_group" "web_server_sg" {
  name_prefix = "EC2-${var.name}-"
  description = "Allow traffic from ALB-${var.name} with HTTP ports open within VPC"

  vpc_id = "${var.vpc_id}"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = "${merge(var.tags, map("Name", "${var.name}-EC2"))}"
}

resource "aws_security_group" "web_server_alb_sg" {
  name_prefix = "ALB-${var.name}-"
  description = "Allow traffic with HTTP and HTTPS ports from any."
  vpc_id      = "${var.vpc_id}"

  lifecycle {
    create_before_destroy = true
  }

  tags = "${merge(var.tags, map("Name", "${var.name}-ALB"))}"
}

resource "aws_security_group_rule" "web_ingress_with_cidr_blocks" {
  count = "${length(var.web_ingress_cidr_blocks)}"

  security_group_id = "${aws_security_group.web_server_alb_sg.id}"
  type              = "ingress"

  cidr_blocks      = ["${var.web_ingress_cidr_blocks}"]
  ipv6_cidr_blocks = ["${var.web_ingress_ipv6_cidr_blocks}"]
  prefix_list_ids  = ["${var.web_ingress_prefix_list_ids}"]
  description      = "${element(var.rules[var.web_ingress[count.index]], 3)}"

  from_port = "${element(var.rules[var.web_ingress[count.index]], 0)}"
  to_port   = "${element(var.rules[var.web_ingress[count.index]], 1)}"
  protocol  = "${element(var.rules[var.web_ingress[count.index]], 2)}"
}

resource "aws_security_group_rule" "web_ingress_with_source_security_group_id" {
  count = "${var.web_number_of_ingress_source_security_group_id}"

  security_group_id = "${aws_security_group.web_server_sg.id}"
  type              = "ingress"

  source_security_group_id = "${lookup(var.web_ingress_source_security_group_id[count.index], "source_security_group_id")}"

  ipv6_cidr_blocks = ["${var.web_ingress_ipv6_cidr_blocks}"]
  prefix_list_ids  = ["${var.web_ingress_prefix_list_ids}"]
  description      = "${lookup(var.web_ingress_source_security_group_id[count.index], "description", "Ingress Rule")}"

  from_port = "${lookup(var.web_ingress_source_security_group_id[count.index], "from_port", element(var.rules[lookup(var.web_ingress_source_security_group_id[count.index], "rule", "_")], 0))}"
  to_port   = "${lookup(var.web_ingress_source_security_group_id[count.index], "to_port", element(var.rules[lookup(var.web_ingress_source_security_group_id[count.index], "rule", "_")], 1))}"
  protocol  = "${lookup(var.web_ingress_source_security_group_id[count.index], "protocol", element(var.rules[lookup(var.web_ingress_source_security_group_id[count.index], "rule", "_")], 2))}"
}

resource "aws_security_group_rule" "alb_ingress_with_cidr_blocks" {
  count = "${length(var.alb_ingress)}"

  security_group_id = "${aws_security_group.web_server_alb_sg.id}"
  type              = "ingress"

  cidr_blocks      = ["${var.alb_ingress_cidr_blocks}"]
  ipv6_cidr_blocks = ["${var.alb_ingress_ipv6_cidr_blocks}"]
  prefix_list_ids  = ["${var.alb_ingress_prefix_list_ids}"]
  description      = "${element(var.rules[var.alb_ingress[count.index]], 3)}"

  from_port = "${element(var.rules[var.alb_ingress[count.index]], 0)}"
  to_port   = "${element(var.rules[var.alb_ingress[count.index]], 1)}"
  protocol  = "${element(var.rules[var.alb_ingress[count.index]], 2)}"
}
