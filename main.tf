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

