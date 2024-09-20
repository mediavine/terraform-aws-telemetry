terraform {
  required_version = ">= 0.13.1"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.35"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.6.3"
    }
    null = {
      source  = "hashicorp/random"
      version = ">= 3.2.3"
    }
  }
}

