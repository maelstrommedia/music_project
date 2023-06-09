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



terraform {
    backend "s3" {
        bucket = "maelstrommedia-state-bucket"
        key    = "music/${var.ver}/${var.stage}/vpc/infa.tf"
        region = "us-east-1"
    }
}
variable "region" {
  default =  "us-east-1"
}

variable "vpc_cidr" {
  default = "10.0.0.0/16"
  type = string
}

resource "aws_vpc" "resume_vpc" {
cidr_block = var.vpc_cidr
enable_dns_support   = true
enable_dns_hostnames = true


tags = {
  Name    = "main-dev-vpc"
  ver = var.ver
  stage = var.stage

}
}

resource "aws_subnet" "resume_subnet_1" {
vpc_id     = aws_vpc.resume_vpc.id
cidr_block = "10.0.1.0/24"
availability_zone = "us-east-1a"

tags = {
  Name = "Resume Dev Subnet Public 1"
  ver = var.ver
  stage = var.stage
}
}

resource "aws_subnet" "resume_subnet_2" {
vpc_id     = aws_vpc.resume_vpc.id
cidr_block = "10.0.2.0/24"
availability_zone = "us-east-1b"

tags = {
  Name = "Resume Dev Subnet Public 2"
  ver = var.ver
  stage = var.stage
}
}

resource "aws_subnet" "resume_subnet_3" {
vpc_id     = aws_vpc.resume_vpc.id
cidr_block = "10.0.3.0/24"
availability_zone = "us-east-1c"

tags = {
  Name = "Resume Subnet Private 1"
  ver = var.ver
  stage = var.stage
}
}

resource "aws_subnet" "resume_subnet_4" {
vpc_id     = aws_vpc.resume_vpc.id
cidr_block = "10.0.4.0/24"
availability_zone = "us-east-1d"

tags = {
  Name = "Resume Subnet Private 4"
  ver = var.ver
  stage = var.stage
}
}


resource "aws_internet_gateway" "resume_igw" {
vpc_id = aws_vpc.resume_vpc.id

tags = {
  Name    = "Resume Internet Gateway"
  ver = var.ver
  stage = var.stage
}
}

resource "aws_route_table" "resume_public_rt" {
vpc_id = aws_vpc.resume_vpc.id

tags = {
  Name    = "Resume Public Route Table"
  ver = var.ver
  stage = var.stage
}
}

resource "aws_route_table" "resume_private_rt" {
vpc_id = aws_vpc.resume_vpc.id

tags = {
  Name    = "Resume Private Route Table"
  ver = var.ver
  stage = var.stage
}
}

resource "aws_route_table_association" "resume_public_subnet_assoc_1" {
subnet_id      = aws_subnet.resume_subnet_1.id
route_table_id = aws_route_table.resume_public_rt.id
}

resource "aws_route_table_association" "resume_public_subnet_assoc_2" {
subnet_id      = aws_subnet.resume_subnet_2.id
route_table_id = aws_route_table.resume_public_rt.id
}

resource "aws_route_table_association" "resume_private_subnet_assoc_3" {
subnet_id      = aws_subnet.resume_subnet_3.id
route_table_id = aws_route_table.resume_private_rt.id
}

resource "aws_route_table_association" "resume_private_subnet_assoc_4" {
subnet_id      = aws_subnet.resume_subnet_4.id
route_table_id = aws_route_table.resume_private_rt.id
}



resource "aws_route" "public-internet-igw-route" {
route_table_id         = aws_route_table.resume_public_rt.id
gateway_id             = aws_internet_gateway.resume_igw.id
destination_cidr_block = "0.0.0.0/0"
}



# Outputs
output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.resume_vpc.id
}

output "public_subnets" {
  description = "IDs of the public subnets"
  value       = [aws_subnet.resume_subnet_1.id, aws_subnet.resume_subnet_2.id]
}

output "private_subnets" {
  description = "IDs of the private subnets"
  value       = [aws_subnet.resume_subnet_3.id, aws_subnet.resume_subnet_4.id]
}

output "internet_gateway_id" {
  description = "The ID of the internet gateway"
  value       = aws_internet_gateway.resume_igw.id
}