output "alb_dns_name" {
  value = aws_lb.app_lb.dns_name
}

output "public_ec2_ip" {
  value = aws_instance.public_ec2.public_ip
}
