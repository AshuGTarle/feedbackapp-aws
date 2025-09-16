terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "eu-north-1"
}

# ----------------------------
# VPC + Networking
# ----------------------------

resource "aws_vpc" "feedbackapp_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "feedbackapp-vpc"
  }
}

resource "aws_subnet" "private1" {
  vpc_id                  = aws_vpc.feedbackapp_vpc.id
  cidr_block              = "10.0.128.0/20"
  availability_zone       = "eu-north-1a"
  map_public_ip_on_launch = false

  tags = {
    Name = "feedbackapp-subnet-private1-eu-north-1a"
  }
}

resource "aws_subnet" "private2" {
  vpc_id                  = aws_vpc.feedbackapp_vpc.id
  cidr_block              = "10.0.16.0/20"
  availability_zone       = "eu-north-1b"
  map_public_ip_on_launch = false

  tags = {
    Name = "feedbackapp-subnet-private2-eu-north-1b"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.feedbackapp_vpc.id

  tags = {
    Name = "feedbackapp-igw"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.feedbackapp_vpc.id

  tags = {
    Name = "feedbackapp-rtb-public"
  }
}

resource "aws_route" "public_internet_access" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.private1.id
  route_table_id = aws_route_table.public.id
}

# ----------------------------
# Security Groups
# ----------------------------

resource "aws_security_group" "alb_sg" {
  name        = "feedbackapp-sg-alb"
  description = "Allow HTTP inbound traffic"
  vpc_id      = aws_vpc.feedbackapp_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "private_ec2_sg" {
  name        = "feedbackapp-sg-private"
  description = "Private EC2 security group"
  vpc_id      = aws_vpc.feedbackapp_vpc.id

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.public_ec2_sg.id]
  }

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.public_ec2_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "public_ec2_sg" {
  name        = "feedbackapp-sg-public"
  description = "Allow HTTP + SSH"
  vpc_id      = aws_vpc.feedbackapp_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["YOUR_IP/32"] # Replace with your IP!
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# ----------------------------
# S3 + CloudWatch
# ----------------------------

resource "aws_s3_bucket" "feedback_bucket" {
  bucket = "feedbackapp-demo-bucket-12345"
}

resource "aws_cloudwatch_log_group" "lambda_logs" {
  name = "/aws/lambda/ImageResizerFunction"
}
