terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 2.1.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region = "eu-west-2"
}

provider "random" {} # Typically optional but explicit declaration ensures clarity.