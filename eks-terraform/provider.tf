terraform {

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.42.0"
    
    }

    random = {
      source  = "hashicorp/random"
      version = "3.1.0"
    }
    
  }
}

provider "aws" {
  region = "eu-west-3"
  access_key = var.access_key
  secret_key = var.secret_key
}


resource "random_string" "suffix" {
  length  = 5
  special = false
}