#terraform file 

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "jenkins_web_server" {
  ami                         = "ami-051f7e7f6c2f40dc1"
  instance_type               = "t2.micro"
  key_name                    = "my_labs_key"
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.jenkins_web_server_security_group.id]

  tags = {
    Name = "Jenkins Web Server"
  }

  user_data = <<-EOF
    #!/bin/bash
    sudo yum update -y 
    sudo wget -O /etc/yum.repos.d/jenkins.repo \
    https://pkg.jenkins.io/redhat-stable/jenkins.repo
    sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key
    sudo yum upgrade -y
    sudo dnf install java-11-amazon-corretto -y
    sudo yum install jenkins -y
    sudo systemctl enable jenkins
    sudo systemctl start jenkins
    EOF
}

resource "aws_security_group" "jenkins_web_server_security_group" {
  name        = "jenkins_web_server_security_group"
  description = "Allow inbound traffic"
  vpc_id      = "vpc-0b47b6adeff3753ef"

  ingress {
    description = "TLS from VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
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

resource "aws_s3_bucket" "myjenkinss3bucket" {
  bucket = "myjenkinss3bucket"
}



