terraform {
  required_version = ">= 1.10.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.85"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.7"
    }
  }

  backend "s3" {
    bucket         = "terraform-bazk-dev-use2"
    region         = "us-east-2"
    dynamodb_table = "bazk-terraform-dev-shared"
    key            = "app/terraform.tfstate"
  }
}

provider "aws" {
  alias  = "use2"
  region = local.region
}

provider "aws" {
  region = "us-east-1"
  alias  = "use1"
  # access_key = var.access_key
  # secret_key = var.secret_key
}

provider "kubernetes" {
  host                   = module.eks["main"].cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks["main"].cluster_certificate_authority_data)
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    args        = ["eks", "get-token", "--cluster-name", module.eks["main"].cluster_name, "--region", local.region]
    command     = "aws"
  }
}

provider "helm" {

  kubernetes {
    host                   = module.eks["main"].cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks["main"].cluster_certificate_authority_data)

    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      # This requires the awscli to be installed locally where Terraform is executed
      args = ["eks", "get-token", "--cluster-name", module.eks["main"].cluster_name]
    }
  }
}