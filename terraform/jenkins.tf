provider "aws" {
  region = "us-east-2"
}

# Get latest Ubuntu 22.04 AMI
data "aws_ami" "ubuntu" {
  most_recent = true

  owners = ["099720109477"] # Canonical (Ubuntu)

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Reference existing Security Group
data "aws_security_group" "jenkins_sg" {
  name = "jenkins-sg"
}

# EC2 Instance
resource "aws_instance" "jenkins_server" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.small"
  key_name      = "MJ1"

  vpc_security_group_ids = [data.aws_security_group.jenkins_sg.id]

  tags = {
    Name = "jenkins-server"
  }
}

# Output public IP
output "jenkins_public_ip" {
  value = aws_instance.jenkins_server.public_ip
}