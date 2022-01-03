# Outputs
output "master-host" {
  description = "Master host IP address"
  value = aws_instance.master-host.public_ip
}
