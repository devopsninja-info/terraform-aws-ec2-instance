resource "aws_security_group" "ec2" {
  name   = var.name
  vpc_id = var.vpc_id
  tags   = local.tags
}

resource "aws_security_group_rule" "ingress_self" {
  security_group_id = aws_security_group.ec2.id

  type      = "ingress"
  self      = true
  from_port = 0
  to_port   = 0
  protocol  = "-1"

  description = "terraform managed"
}

resource "aws_security_group_rule" "ingress_ssh" {
  count = length(var.allow_ssh_access_from) > 0 ? 1 : 0

  security_group_id = aws_security_group.ec2.id

  type      = "ingress"
  from_port = 22
  to_port   = 22
  protocol  = "tcp"

  cidr_blocks = var.allow_ssh_access_from
  description = "terraform managed"
}

resource "aws_security_group_rule" "egress" {
  security_group_id = aws_security_group.ec2.id

  type      = "egress"
  from_port = 0
  to_port   = 0
  protocol  = "-1"

  cidr_blocks = ["0.0.0.0/0"] #tfsec:ignore:AWS007
  description = "terraform managed"
}

// custom ingress cidr rules
resource "aws_security_group_rule" "ingress_cidr_rules" {
  count = length(var.ingress_cidr_rules)

  security_group_id = aws_security_group.ec2.id

  type = "ingress"
  /*
   *  super ugly split thing, allows to specify single port
   *  or port range in a form "from-to", eg: 3200-3300
   */
  from_port = split("-", var.ingress_cidr_rules[count.index][0])[0]
  to_port   = length(split("-", var.ingress_cidr_rules[count.index][0])) > 1 ? split("-", var.ingress_cidr_rules[count.index][0])[1] : split("-", var.ingress_cidr_rules[count.index][0])[0]
  protocol  = var.ingress_cidr_rules[count.index][1]

  cidr_blocks = [var.ingress_cidr_rules[count.index][2]]
  description = "terraform managed"
}

// custom ingress security group rules
resource "aws_security_group_rule" "ingress_sg_rules" {
  count             = length(var.ingress_sg_rules)
  security_group_id = aws_security_group.ec2.id

  type = "ingress"
  /*
   *  super ugly split thing, allows to specify single port
   *  or port range in a form "from-to", eg: 3200-3300
   */
  from_port = split("-", var.ingress_sg_rules[count.index][0])[0]
  to_port   = length(split("-", var.ingress_sg_rules[count.index][0])) > 1 ? split("-", var.ingress_sg_rules[count.index][0])[1] : split("-", var.ingress_sg_rules[count.index][0])[0]
  protocol  = var.ingress_cidr_rules[count.index][1]

  source_security_group_id = var.ingress_sg_rules[count.index][2]
  description              = "terraform managed"
}
