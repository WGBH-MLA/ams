output "fcrepo_prod_connection_string" {
  description = "Copy/Paste/Enter - You are in the matrix"
  value = [
    for k, v in module.ec2.fcrepo_ips : "${k} ~ ssh -i ./ops/provision/${module.ssh.key_name}.pem ec2-user@${v}"
  ]
}
