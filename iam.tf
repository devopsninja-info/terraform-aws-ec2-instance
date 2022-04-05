data "aws_iam_policy_document" "ec2" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ec2" {
  name               = "${local.account_name_titled}EC2${local.name_titled}"
  assume_role_policy = data.aws_iam_policy_document.ec2.json
}

resource "aws_iam_instance_profile" "ec2" {
  name = "${local.account_name_titled}EC2${local.name_titled}"
  role = aws_iam_role.ec2.name
}

resource "aws_iam_role_policy_attachment" "ec2common" {
  count = var.attach_ec2-common_policy ? 1 : 0

  role       = aws_iam_role.ec2.name
  policy_arn = "arn:aws:iam::${var.account_id}:policy/${local.account_name_titled}EC2Common"
}

resource "aws_iam_role_policy_attachment" "extra" {
  count = length(var.attach_extra_policies)

  role       = aws_iam_role.ec2.name
  policy_arn = var.attach_extra_policies[count.index]
}
