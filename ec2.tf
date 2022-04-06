resource "aws_instance" "ec2" {
  count = var.instance_count

  ami           = local.instance_ami
  instance_type = var.instance_type
  key_name      = var.instance_key_name

  iam_instance_profile = "${local.account_name_titled}EC2${local.name_titled}"
  user_data            = local.user_data

  tags = local.tags

  network_interface {
    device_index          = 0
    network_interface_id  = aws_network_interface.ec2[count.index].id
    delete_on_termination = false
  }

  root_block_device {
    delete_on_termination = true
    encrypted             = false
    iops                  = 0
    volume_size           = var.instance_disk_size
    volume_type           = "gp2"
  }

  metadata_options {
    http_endpoint               = var.metadata_endpoint_enabled ? "enabled" : "disabled"
    http_put_response_hop_limit = var.metadata_hop_limit
    http_tokens                 = var.metadata_tokens_required ? "required" : "optional"
    instance_metadata_tags      = var.metadata_tags_enabled ? "enabled" : "disabled"
  }

  depends_on = [
    aws_iam_role.ec2,
    aws_iam_instance_profile.ec2,
    aws_iam_role_policy_attachment.ec2common,
  ]
}

resource "aws_network_interface" "ec2" {
  count = var.instance_count

  subnet_id         = var.subnet_id
  security_groups   = compact(concat([aws_security_group.ec2.id], var.extra_security_group_ids))
  source_dest_check = var.instance_eni_source_dest_check
  tags              = local.tags
}

resource "aws_eip" "ec2" {
  count = var.instance_eip_enabled ? var.instance_count : 0

  vpc               = true
  network_interface = aws_network_interface.ec2[count.index].id
  tags              = local.tags
}

data "aws_subnet" "ec2" {
  count = var.instance_extra_ebs_size > 0 ? 1 : 0

  id = var.subnet_id
}

resource "aws_ebs_volume" "ec2" {
  count = var.instance_extra_ebs_size > 0 ? var.instance_count : 0

  availability_zone = data.aws_subnet.ec2[0].availability_zone
  type              = "gp2"
  size              = var.instance_extra_ebs_size
  tags = merge(
    local.tags,
    { "Name" : "${var.name}-xvdb" },
  )
}

resource "aws_volume_attachment" "ebs_att" {
  count = var.instance_extra_ebs_size > 0 ? var.instance_count : 0

  device_name = "/dev/xvdb"
  volume_id   = aws_ebs_volume.ec2[count.index].id
  instance_id = aws_instance.ec2[count.index].id
}
