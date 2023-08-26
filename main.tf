#terraform file 

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "jenkins_web_server" {                            
  ami           = "ami-08a52ddb321b32a8c"                          
  instance_type = "t2.micro"                                      
  
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
    sudo amazon-linux-extras install java-openjdk11 -y
    yum install jenkins -y
    systemctl enable jenkins
    systemctl start jenkins
    EOF
}

resource "aws_security_group" "jenkins_web_server_security_group" {
  name        = "jenkins_web_server_security_group"
  description = "Allow inbound traffic"
  vpc_id      = "vpc-0b47b6adeff3753ef"

  ingress {
    description      = "TLS from VPC"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    
  }
  
  ingress {
    from_port        = 8080
    to_port          = 8080
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }
  
}

resource "aws_s3_bucket" "my_jenkins_s3_bucket" {
  bucket = "my_jenkins_s3_bucket"
}

