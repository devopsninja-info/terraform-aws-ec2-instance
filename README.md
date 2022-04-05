# version 
0.1.0  ([changelog](./CHANGELOG.md))

# usage
```
module "ec2" {
  source = "git@github.com:devopsninja-info/terraform-aws-ec2-instance.git?ref=0.1.0"

  account_id   = "..." // required,
  account_name = "..." // required,
  name         = "..." // required,

  vpc_id    = "..."    // required,
  subnet_id = "..."    // required,

  allow_ssh_access_from    = []                // default,
  ingress_cidr_rules       = []                // default,
  ingress_sg_rules         = []                // default,
  extra_security_group_ids = []                // default,

  instance_count                  = 1          // default,
  instance_ami                    = ""         // default, empty string means, latest aws linux 2
  instance_type                   = "t2.micro" // default,
  instance_key_name               = "default"  // default,
  instance_disk_size              = 8          // default,
  instance_eip_enabled            = true       // default,
  instance_eni_source_dest_check  = true       // default,
  instance_extra_user_data        = ""         // default,
  instance_extra_ebs_size         = 0          // default,
  instance_extra_ebs_mount_points = []         // default,

  attach_ec2-common_policy = true              // default,
  attach_extra_policies    = []                // default,

  bootstrap            = false                 // default,
  bootstrap_entrypoint = "main.sh"             // default,

  metadata_endpoint_enabled = true             // default,
  metadata_hop_limit        = 1                // default,
  metadata_tokens_required  = true             // default,
}
```
