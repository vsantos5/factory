module "vpc" {
  for_each = { for vpcs in local.workspace.vpc : vpcs.name => vpcs }
  source   = "../../tfmodules/vpc"

  vpc_cidr               = each.value.cidr_block
  name                   = try(each.value.name, "")
  vpc_name               = try(each.value.vpc_name, "")
  create_database_subnet = true
  enable_flow_logs       = true
  public_subnets         = try(each.value.public_subnets, null)

  private_subnets               = try(each.value.private_subnets, null)
  classic_private_subnets       = false
  one_nat_gateway_per_az        = false
  private_dedicated_network_acl = true
  private_inbound_acl_rules     = local.acl_rules
  private_outbound_acl_rules    = local.acl_rules
  database_subnets              = try(each.value.database_subnets, null)

  database_dedicated_network_acl = true
  database_inbound_acl_rules     = local.acl_rules
  database_outbound_acl_rules    = local.acl_rules

  tags = local.default_tags
}