output "vpc" {
  value = module.vpc
}

output "sg_pub_id" {
  value = aws_security_group.access.id
}
