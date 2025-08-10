output "web_instance_ids" {
  value = aws_instance.web[*].id
}

output "server_instance_ips" {
  value = { for k, v in aws_instance.servers : k => v.public_ip }
}