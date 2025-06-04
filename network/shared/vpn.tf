module "vpn" {
  #for_each = { for vpns in local.workspace.vpn : vpns.name => vpns }
  source   = "../../tfmodules/vpn"

  vpc_name = "vpc-${local.workspace.vpc[0].name}"
  cgw_name = "${local.workspace.vpc[0].name}-VPN1"
  tgw_name = "tgw-${local.workspace.tgw[0].name}"

  tags = local.default_tags

  depends_on = [module.vpc["bazk-net"]]
}