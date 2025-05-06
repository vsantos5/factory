module "vpn_gateway" {
  source  = "terraform-aws-modules/vpn-gateway/aws"
  version = "~> 3.0"

  vpc_id              = data.aws_vpc.network.id
  transit_gateway_id  = data.aws_ec2_transit_gateway.network.id
  customer_gateway_id = data.aws_customer_gateway.network.id

  tunnel_inside_ip_version = "ipv4"
/*
  # tunnel inside cidr & preshared keys (optional)
  tunnel1_inside_cidr   = "169.254.44.88/30"
  tunnel2_inside_cidr   = "169.254.44.100/30"
  tunnel1_preshared_key = "1234567890abcdefghijklmn"
  tunnel2_preshared_key = "abcdefghijklmn1234567890"
*/
  create_vpn_gateway_attachment      = false
  connect_to_transit_gateway         = true
#  vpn_connection_enable_acceleration = true

  tags = var.tags
}