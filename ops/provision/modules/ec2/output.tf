output "fcrepo_ips" {
  value = {
    for k, v in aws_instance.fcrepo : k => v.public_ip
  }
}
