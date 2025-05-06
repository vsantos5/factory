locals {
  region = "us-east-2"

  config    = yamldecode(file("config.yaml"))
  workspace = local.config["workspaces"][var.env]

  acl_rules = [
    {
      "rule_number" : 100,
      "cidr_block" : "10.100.0.0/16",
      "from_port" : 0,
      "to_port" : 0,
      "protocol" : "-1",
      "rule_action" : "deny"
    },
    {
      "rule_number" : 200,
      "cidr_block" : "10.105.0.0/16",
      "from_port" : 0,
      "to_port" : 0,
      "protocol" : "-1",
      "rule_action" : "deny"
    },
    {
      "rule_number" : 300,
      "cidr_block" : "0.0.0.0/0",
      "from_port" : 0,
      "to_port" : 0,
      "protocol" : "-1",
      "rule_action" : "allow"
    }
  ]

  default_tags = {
    Enviroment = var.env
    #Service      = "#{Service}#"
    Owner        = "Cloud Infrastructure Team"
    Description  = "Resource created by Terraform"
    CostType     = "CostType"
    Created_date = timestamp()
    Repo         = var.repository_name
    Builder      = "terraform"
  }
}