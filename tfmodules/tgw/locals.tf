locals {
  region = "us-east-2"

  tgw_name             = "tgw-${var.tgw_name}"
  tgw_rtb_name         = "tgw-rtb-${var.tgw_route_table_name}"
  tgw_default_rtb_name = "tgw-rtb-${var.tgw_default_route_table_name}"
  tgw_tags             = merge(var.tgw_tags, { Name = local.tgw_name })
  tgw_rtb_tags         = merge(var.tgw_route_table_tags, { Name = local.tgw_rtb_name })
  tgw_default_rtb_tags = merge(var.tgw_default_route_table_tags, { Name = local.tgw_default_rtb_name })
  ram_name             = "ram-${local.tgw_name}"
  ram_tags             = { Name = local.ram_name }
  ram_principals       = !var.enable_share_tgw ? [] : var.enable_share_tgw_with_all_organization ? setunion([data.aws_organizations_organization.this.arn], var.ram_principals) : var.ram_principals

  tags = {
    Enviroment   = var.env
    #Service      = "Service"
    Owner        = "Bazk Infrastructure"
    Description  = "Resource created by Terraform"
    CostType     = "CostType"
    Created_date = timestamp()
    Repo         = var.repository_name
    Builder      = "terraform"
  }
}