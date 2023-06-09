provider "aws" {
  shared_credentials_files = ["/mnt/c/Users/dones/.aws/credentials"]
    region = "us-east-1"
}

variable "stage" {
  type = string
  default ="test"
}

variable "ver" {
  type = string
  default ="1"
}
variable "tf_resource" {
  type = string
}
variable "region" {
  default =  "us-east-1"
}

variable "sgname" {
    type = string
}






data "terraform_remote_state" "vpc_state" {
  backend = "s3"

  config = {
        bucket = "maelstrommedia-state-bucket"
        key="music/1/test/vpc/infa.tf"
    region = "us-east-1"
  }
}


resource "aws_security_group" "server-sg" {
  name        = "redis-ec2-sg"
  description = "Security group for the Redis Server"
  vpc_id      = data.terraform_remote_state.vpc_state.outputs.vpc_id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow incoming traffic on port 80 from any IP
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow incoming traffic on port 6379 from any IP
  ingress {
    from_port   = 6379
    to_port     = 6379
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

    ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "ssh"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  
  # Add egress block if you want to control outgoing traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "redis-ec2-sg"
    ver = var.ver
    stage = var.stage
  }
}




terraform {
    backend "s3" {
        bucket = "maelstrommedia-state-bucket"
        key="music/1/test/server/redis/sg/infa.tf"
        region = "us-east-1"
    }
}



output "security_group_id" {
  description = "The ID of the security group"
  value       = aws_security_group.server-sg.id
}

output "security_group_name" {
  description = "The name of the security group"
  value       = aws_security_group.server-sg.name
}

output "security_group_description" {
  description = "The description of the security group"
  value       = aws_security_group.server-sg.description
}

output "security_group_vpc_id" {
  description = "The VPC ID where the security group is in"
  value       = aws_security_group.server-sg.vpc_id
}