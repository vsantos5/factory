locals {
  region = "us-east-2"
  region_alias = "use2"

  config    = yamldecode(file("../config.yaml"))
  workspace = local.config["workspaces"][var.env]
  
  default_tags = {
    Enviroment = var.env
    #Service      = "#{Service}#"
    Owner        = "Bazk Develonment Team"
    Description  = "Resource created by Terraform"
    CostType     = "CostType"
    Created_date = timestamp()
    Repo         = var.repository_name
    Builder      = "terraform"
  }
}