
data "terraform_remote_state" "vpc" {
  backend = "s3"
  config = {
    key            = "shared/terraform.tfstate"
    bucket         = "bazk-terraform-net-use2"
    dynamodb_table = "bazk-terraform-network-shared"
    region         = "us-east-2"
  }
}

data "aws_organizations_organization" "this" {}