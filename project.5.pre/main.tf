terraform {
  required_version = ">= 1.1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.60"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

provider "aws" {
  alias  = "west"
  region = "us-west-2"
}

locals {
  prefix = var.prefix

  common_tags = {
    Project     = var.project
    Owner       = var.contact
    ManagedBy   = "Terraform"
  }
}
