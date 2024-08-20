terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.63.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  alias  = "nv"
  region = "us-east-1"
}

provider "aws" {
  alias  = "mumbai"
  region = "ap-south-1"
}


