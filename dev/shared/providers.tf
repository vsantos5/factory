terraform {
  required_version = ">= 1.10.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.85"
    }
  }

  backend "s3" {
    bucket         = "terraform-bazk-dev-use2"
    region         = "us-east-2"
    dynamodb_table = "bazk-terraform-dev-shared"
    key            = "shared/terraform.tfstate"
  }
}

provider "aws" {
  alias  = "use2"
  region = local.region
}