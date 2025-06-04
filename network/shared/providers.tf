terraform {
  required_version = ">= 1.10.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.85"
    }
  }

  backend "s3" {
    bucket         = "terraform-vini-net-use2"
    region         = "us-east-2"
    key            = "shared/terraform.tfstate"
    encrypt        = true
    use_lockfile   = true
  }
}

provider "aws" {
  alias  = "use2"
  region = local.region
}