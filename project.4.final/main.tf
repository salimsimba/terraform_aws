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

resource "aws_codecommit_repository" "code_repo" {
  description     = "KoofeeLuv App Repository"
  repository_name = var.app_code_repository_name
}

resource "null_resource" "image" {
  provisioner "local-exec" {
    command = <<EOF
              git init
              git add .
              git commit -m "Initial Commit"
              git remote add origin ${aws_codecommit_repository.code_repo.clone_url_http}
              git push -u origin master
              EOF
    working_dir = "app"
  }

  depends_on = [ aws_codecommit_repository.code_repo ]
}

resource "null_resource" "clean_up" {
  provisioner "local-exec" {
    when        = destroy
    command     = "rm -rf .git/"
    working_dir = "app"
  }
}

resource "aws_s3_bucket" "cicd_bucket" {
  bucket        = var.artifacts_bucket_name
  acl           = "private"
  force_destroy = true
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
