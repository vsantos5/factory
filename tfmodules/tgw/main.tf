module "tgw_core" {
  source  = "terraform-aws-modules/transit-gateway/aws"
  version = "2.13.0"

  amazon_side_asn                        = var.amazon_side_asn
  transit_gateway_cidr_blocks            = var.transit_gateway_cidr_blocks
  enable_auto_accept_shared_attachments  = var.enable_auto_accept_shared_attachments
  enable_vpn_ecmp_support                = var.enable_vpn_ecmp_support
  enable_dns_support                     = var.enable_dns_support
  enable_multicast_support               = var.enable_multicast_support
  enable_default_route_table_propagation = var.enable_default_route_table_propagation
  enable_default_route_table_association = var.enable_default_route_table_association

  share_tgw                     = var.enable_share_tgw
  description                   = coalesce(var.description, local.tgw_name)
  ram_name                      = local.ram_name
  ram_allow_external_principals = var.enable_ram_allow_external_principals
  ram_principals                = local.ram_principals
  ram_tags                      = local.ram_tags

  tgw_tags                     = local.tgw_tags
  tgw_route_table_tags         = local.tgw_rtb_tags
  tgw_default_route_table_tags = local.tgw_default_rtb_tags

  tags = var.tags
}

resource "aws_ec2_transit_gateway_vpc_attachment_accepter" "this" {
  for_each                      = var.enable_auto_accept_shared_attachments ? {} : var.tgw_attachment_vpc_accepters
  transit_gateway_attachment_id = each.value
}