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
variable "ecr_name" {
    default = "music-dev-repo"
}

variable "role_name" {
  type = string
}

terraform {
    backend "s3" {
        bucket = "maelstrommedia-state-bucket"
        key="music/1/test/server/redis/role/infa.tf"
        region = "us-east-1"
    }
}



data "local_file" "arns" {
  filename = "${path.cwd}/arn.json"
}

locals {
  arns = jsondecode(data.local_file.arns.content)
}

resource "aws_iam_role" "server_role" {
  name = var.role_name
      tags = {

  ver = var.ver
  stage = var.stage

}

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "server_role_att" {
  count      = length(local.arns)
  role       = aws_iam_role.server_role.name
  policy_arn = local.arns[count.index]
}

resource "aws_iam_role" "ec2_role" {
  name = "ec2-${var.role_name}-role"
      tags = {

  ver = var.ver
  stage = var.stage

}

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "ec2-${var.role_name}-role-ip"
  role = aws_iam_role.ec2_role.name
    tags = {

  ver = var.ver
  stage = var.stage

}
}


output "server_role_arn" {
  description = "The ARN of the server role"
  value       = aws_iam_role.server_role.arn
}

output "server_role_policy_arns" {
  description = "The ARNs of the policies attached to the server role"
  value       = [for i in aws_iam_role_policy_attachment.server_role_att : i.policy_arn]
}

output "ec2_role_arn" {
  description = "The ARN of the EC2 role"
  value       = aws_iam_role.ec2_role.arn
}

output "ec2_instance_profile_arn" {
  description = "The ARN of the EC2 instance profile"
  value       = aws_iam_instance_profile.ec2_profile.arn
}