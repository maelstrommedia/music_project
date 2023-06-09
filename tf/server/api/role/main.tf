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


terraform {
    backend "s3" {
        bucket = "maelstrommedia-state-bucket"
        key    = "music/${var.ver}/${var.stage}/${var.tf_resource}/infa.tf"
        region = "us-east-1"
    }
}



resource "aws_ecr_repository" "my_repo" {
  name = "${var.ecr_name}"

  image_tag_mutability = "IMMUTABLE"
  tags = {
  Name    = var.ecr_name
  ver = var.ver
  stage = var.stage

}

     


}


output "ecr_repository_uri" {
    description = "The URI of the ECR repository"
    value       = aws_ecr_repository.my_repo.repository_url
  }
