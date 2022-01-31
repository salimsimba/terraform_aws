terraform {
  required_version = ">= 1.1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.60"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.1.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

resource "null_resource" "image" {
  provisioner "local-exec" {
    command = <<EOF
              docker build -t ${var.app_image_name} .
              aws ecr get-login-password --region ${var.aws_region} | docker login --username AWS --password-stdin ${local.account_id}.dkr.ecr.${var.aws_region}.amazonaws.com
              docker tag ${var.app_image_name} ${local.account_id}.dkr.ecr.${var.aws_region}.amazonaws.com/${var.app_image_name}
              docker push ${local.account_id}.dkr.ecr.${var.aws_region}.amazonaws.com/${var.app_image_name}
              EOF
    working_dir = "app"
  }

  depends_on = [ aws_ecr_repository.repository ]
}

resource "null_resource" "clean_up" {
  provisioner "local-exec" {
    when        = destroy
    command     = "rm -rf .git/"
    working_dir = "app"
  }
}

locals {
  account_id      = data.aws_caller_identity.current.account_id
  current_account = format("arn:aws:iam::%s:root", data.aws_caller_identity.current.account_id)
  prefix          = var.prefix

  common_tags = {
    Project     = var.project
    Owner       = var.contact
    ManagedBy   = "Terraform"
  }
}

data "aws_ami" "amazon_linux" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn-ami*amazon-ecs-optimized"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["amazon"]
}

data "aws_region" "current" {}
data "aws_caller_identity" "current" {}
