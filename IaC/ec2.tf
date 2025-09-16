resource "aws_instance" "public_ec2" {
  ami           = var.ami_id
  instance_type = var.instance_type
  subnet_id     = aws_subnet.public_a.id
  key_name      = aws_key_pair.feedback_key.key_name
  vpc_security_group_ids = [aws_security_group.sg_public.id]

  tags = {
    Name    = "feedbackapp-ec2-public"
    Project = "FeedbackApp"
  }

  user_data = <<-EOF
              #!/bin/bash
              dnf update -y
              dnf install -y httpd php mariadb105
              systemctl start httpd
              systemctl enable httpd
              echo "<h1>Welcome to FeedbackApp – Public Web Server</h1>" > /var/www/html/index.html
              EOF
}

resource "aws_instance" "private_ec2" {
  ami           = var.ami_id
  instance_type = var.instance_type
  subnet_id     = aws_subnet.private_a.id
  key_name      = aws_key_pair.feedback_key.key_name
  vpc_security_group_ids = [aws_security_group.sg_private.id]

  tags = {
    Name    = "feedbackapp-ec2-private"
    Project = "FeedbackApp"
  }

  user_data = <<-EOF
              #!/bin/bash
              dnf update -y
              dnf install -y mariadb105-server
              systemctl start mariadb
              systemctl enable mariadb
              mysql -e "CREATE DATABASE feedbackdb;"
              EOF
}
