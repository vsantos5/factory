module "vpc" {
  for_each = { for vpcs in local.workspace.vpc : vpcs.name => vpcs }
  source   = "../../tfmodules/vpc"

  vpc_cidr         = each.value.cidr_block
  name             = try(each.value.name, "")
  vpc_name         = try(each.value.vpc_name, "")
  enable_flow_logs = true
  public_subnets   = try(each.value.public_subnets, null)
  private_subnets  = try(each.value.private_subnets, null)

  enable_vpn_gateway = true
  amazon_side_asn    = each.value.customer_gateway[0].bgp_asn
  customer_gateways = {
    VPN1 = {
      bgp_asn    = each.value.customer_gateway[0].bgp_asn
      ip_address = each.value.customer_gateway[0].ip_address
    }
  }

  tags = local.default_tags
}