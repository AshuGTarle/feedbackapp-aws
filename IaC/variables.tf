variable "region" {
  default = "eu-north-1"
}

variable "instance_type" {
  default = "t3.micro"
}

variable "ami_id" {
  # Amazon Linux 2023 AMI in eu-north-1
  default = "ami-0fd2b85ee2b4dc969"
}
