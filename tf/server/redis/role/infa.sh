#!/bin/bash

# Run Python script
python3 infa.py

# Initialize Terraform
terraform init -backend-config="infa.config"

# Apply changes with var file
terraform apply -var-file="terraform.tfvars" -auto-approve

# Remove .terraform directory
rm -rf .terraform
rm -rf .terraform.lock.hcl