output "outputs" {
  value = {
    "instance_id"        = length(aws_instance.ec2) > 0 ? aws_instance.ec2[0].id : ""
    "instance_ids"       = aws_instance.ec2.*.id
    "public_ip"          = length(aws_instance.ec2) > 0 ? aws_instance.ec2[0].public_ip : ""
    "public_ips"         = aws_instance.ec2.*.public_ip
    "private_ip"         = length(aws_instance.ec2) > 0 ? aws_instance.ec2[0].private_ip : ""
    "private_ips"        = aws_instance.ec2.*.private_ip
    "security_group_id"  = aws_security_group.ec2.id
    "availability_zone"  = length(aws_instance.ec2) > 0 ? aws_instance.ec2[0].availability_zone : ""
    "availability_zones" = aws_instance.ec2.*.availability_zone
    "iam_role_name"      = aws_iam_role.ec2.name
  }
}
