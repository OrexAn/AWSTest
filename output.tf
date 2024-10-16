output "ubuntu_instance_id" {
  description = "ID of the Ubuntu EC2 instance"
  value = aws_instance.app_server_1.id
}

output "linux_instance_id" {
  description = "ID of the Linux EC2 instance"
  value = aws_instance.app_server_2.id
}

output "ubuntu_instance_public_id" {
  description = "Public IP address of the Ubuntu EC2 instance"
  value = aws_instance.app_server_1.public_ip
}

output "linux_instance_public_id" {
  description = "Public IP address of the Linux EC2 instance"
  value = aws_instance.app_server_2.public_ip
}