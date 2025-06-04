module "tgw" {
  for_each = { for tgws in local.workspace.tgw : tgws.name => tgws }
  source   = "../../tfmodules/tgw"

  name                                   = try(each.value.name, "")
  tgw_name                               = try(each.value.name, "")
  amazon_side_asn                        = try(each.value.asn, "")
  enable_share_tgw                       = true
  enable_share_tgw_with_all_organization = true
  enable_auto_accept_shared_attachments  = false

  tags = local.default_tags
}