// {{{ data
data "aws_ami" "ami" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-2.0*x86_64-gp2"]
  }
}
// }}}

// {{{ variables

// {{{ account
variable "account_name" {
  type = string
}

variable "account_id" {
  type = string
}
// }}}

// {{{ network and access
variable "vpc_id" {
  type = string
}

variable "subnet_id" {
  type = string
}

variable "allow_ssh_access_from" {
  type    = list(string)
  default = []
}

/*
 * ingress_cidr_rules
 *   
 * example:
 *   [
 *     ["80",        "tcp", "0.0.0.0/0"],
 *     ["443",       "tcp", "0.0.0.0/0"],
 *     ["8080-8081", "udp", "87.239.222.103/32"],
 *   ]
 *
 */
variable "ingress_cidr_rules" {
  type    = list(list(string))
  default = []
}

/*
 * ingress_sg_rules
 *
 * example:
 *   [
 *     ["80",    "tcp", "sg-abc012"],
 *     ["80-81", "udp", "sg-abc012"],
 *   ]
 *
 */
variable "ingress_sg_rules" {
  type    = list(list(string))
  default = []
}

variable "extra_security_group_ids" {
  type    = list(string)
  default = []
}
// }}}

// {{{ instance
variable "name" {
  type = string
}

variable "instance_count" {
  type    = number
  default = 1
}

variable "instance_ami" {
  type    = string
  default = ""
}

variable "instance_type" {
  type    = string
  default = "t2.micro"
}

variable "instance_key_name" {
  type    = string
  default = "default"
}

variable "instance_disk_size" {
  type    = number
  default = 8
}

variable "instance_eip_enabled" {
  type    = bool
  default = true
}

variable "instance_eni_source_dest_check" {
  type    = bool
  default = true
}

variable "instance_extra_user_data" {
  type    = string
  default = ""
}

variable "instance_extra_ebs_size" {
  type    = number
  default = 0
}

variable "instance_extra_ebs_mount_points" {
  type    = list(string)
  default = []
}

variable "bootstrap" {
  type    = bool
  default = false
}

variable "bootstrap_s3_bucket" {
  type    = string
  default = ""
}

variable "bootstrap_entrypoint" {
  type    = string
  default = "main.sh"
}

variable "attach_ec2-common_policy" {
  type    = bool
  default = true
}

variable "attach_extra_policies" {
  type    = list(string)
  default = []
}
// }}}

/// {{{ metadata_options
variable "metadata_endpoint_enabled" {
  type    = bool
  default = true
}

variable "metadata_hop_limit" {
  type    = number
  default = 1
}

variable "metadata_tokens_required" {
  type    = bool
  default = true
}

variable "metadata_tags_enabled" {
  type    = bool
  default = false
}
/// }}}

variable "extra_tags" {
  type    = map(any)
  default = {}
}
// }}}

// {{{ locals
locals {
  instance_ami = var.instance_ami == "" ? data.aws_ami.ami.id : var.instance_ami

  name_titled         = replace(title(var.name), "-", "")
  account_name_titled = replace(title(var.account_name), "-", "")

  tags = merge(
    {
      "Name"            = var.name
      "user:managed_by" = "terraform"
    },
    var.extra_tags,
  )

  bootstrap_s3_bucket = length(var.bootstrap_s3_bucket) > 0 ? var.bootstrap_s3_bucket : "${var.account_name}-ec2-bootstrap"

  user_data = <<-EOF
#!/bin/bash -

exec > /var/log/user-data.log 2>&1

echo "[START] $(date -u)"

%{if length(var.instance_extra_ebs_mount_points) > 0~}
cat > /etc/ebs_volumes <<EOT
%{for mount_point in var.instance_extra_ebs_mount_points~}
${mount_point}
%{endfor~}
EOT
%{endif~}

%{if length(var.instance_extra_user_data) > 0~}
${var.instance_extra_user_data}

%{endif~}
%{if var.bootstrap~}
aws s3 cp s3://${local.bootstrap_s3_bucket}/${var.bootstrap_entrypoint} - | bash -s -- ${var.account_name}
%{endif~}
echo "[END] $(date -u)"
  EOF

}
// }}}
