module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.19.0"

  name                              = var.name
  cidr                              = var.vpc_cidr
  secondary_cidr_blocks             = var.vpc_secondary_cidr_blocks
  azs                               = local.azs
  private_subnets                   = local.private_subnets
  intra_subnets                     = local.intra_subnets
  public_subnets                    = var.public_subnets
  database_subnets                  = local.database_subnets
  enable_dns_hostnames              = true
  enable_dns_support                = true
  enable_vpn_gateway                = var.enable_vpn_gateway
  amazon_side_asn                   = var.amazon_side_asn
  create_database_nat_gateway_route = true
  create_database_subnet_group      = false
  map_public_ip_on_launch           = var.map_public_ip_on_launch

  vpc_tags = merge (
    {
      Name = local.vpc_name
    },
    var.tags
  )

  ##########################################################
  # DHCP Options
  ##########################################################
  enable_dhcp_options              = true
  dhcp_options_domain_name         = "ec2.internal"
  dhcp_options_domain_name_servers = ["AmazonProvidedDNS"]

  dhcp_options_tags = {
    Name = local.dhcp_options_name
  }

  ######################################################
  # SUBNETS PÚBLICAS
  ######################################################
  public_subnet_names          = local.public_subnet_names
  public_subnet_tags           = var.public_subnet_tags
  public_dedicated_network_acl = var.public_dedicated_network_acl
  public_inbound_acl_rules     = var.public_inbound_acl_rules
  public_outbound_acl_rules    = var.public_outbound_acl_rules

  public_route_table_tags = {
    "Name" = local.public_route_table_name
  }

  public_acl_tags = {
    "Name" = local.public_acl_name
  }

  igw_tags = {
    Name = local.igw_name
  }

  ######################################################
  # SUBNETS PRIVADAS
  ######################################################
  private_subnet_names          = local.private_subnet_names
  private_subnet_tags           = var.private_subnet_tags
  private_dedicated_network_acl = var.private_dedicated_network_acl && length(var.private_subnets) > 0 ? var.private_dedicated_network_acl : false
  private_inbound_acl_rules     = var.private_inbound_acl_rules
  private_outbound_acl_rules    = var.private_outbound_acl_rules
  enable_nat_gateway            = local.enable_nat_gateway
  one_nat_gateway_per_az        = local.one_nat_gateway_per_az
  single_nat_gateway            = local.single_nat_gateway

  private_route_table_tags = {
    "Name" = local.private_route_table_name
  }

  private_acl_tags = {
    "Name" = local.private_acl_name
  }

  nat_gateway_tags = {
    Name = local.nat_gw_name
  }

  nat_eip_tags = {
    Name = local.nat_eip_name
  }

  ######################################################
  # SUBNETS INTRA (Sem rota para NAT)
  ######################################################
  intra_subnet_names          = local.private_subnet_names
  intra_subnet_tags           = var.private_subnet_tags
  intra_dedicated_network_acl = var.private_dedicated_network_acl && length(var.private_subnets) > 0 ? var.private_dedicated_network_acl : false
  intra_inbound_acl_rules     = var.private_inbound_acl_rules
  intra_outbound_acl_rules    = var.private_outbound_acl_rules

  intra_acl_tags = {
    "Name" = local.private_acl_name
  }

  intra_route_table_tags = {
    "Name" = local.intra_route_table_name
  }

  ######################################################
  # SUBNETS DATABASE
  ######################################################
  database_subnet_names              = local.database_subnet_names
  create_database_subnet_route_table = true
  database_dedicated_network_acl     = var.database_dedicated_network_acl && length(var.database_subnets) > 0 ? var.database_dedicated_network_acl : false
  database_inbound_acl_rules         = var.database_inbound_acl_rules
  database_outbound_acl_rules        = var.database_outbound_acl_rules

  database_route_table_tags = {
    "Name" = local.database_route_table_name
  }

  database_acl_tags = {
    "Name" = local.database_acl_name
  }

  ########################################
  # RECURSOS DEFAULT
  ########################################
  manage_default_network_acl    = true
  manage_default_route_table    = true
  manage_default_security_group = true

  default_network_acl_name    = local.default_nacl_name
  default_route_table_name    = local.default_route_table_name
  default_security_group_name = "default"

  default_security_group_ingress = []
  default_security_group_egress  = []

  ########################################
  # VPC FLOW LOGS
  ########################################
  enable_flow_log           = var.enable_flow_logs
  flow_log_traffic_type     = "REJECT"
  flow_log_destination_type = "s3"
  flow_log_destination_arn  = local.flow_log_destination_arn
  flow_log_file_format      = "parquet"

  vpc_flow_log_tags = {
    Name = local.flow_logs_name
  }

  tags = var.tags
}

############################
# VPC FLOW LOGS - STORAGE
############################
module "s3_bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "3.10.1"
  count   = local.create_flow_logs_bucket

  bucket            = local.flow_logs_bucket
  block_public_acls = true
  force_destroy     = var.flow_logs_s3_force_destroy

  versioning = {
    status     = var.flow_logs_s3_versioning
    mfa_delete = false
  }

  server_side_encryption_configuration = {
    rule = {
      apply_server_side_encryption_by_default = {
        kms_master_key_id = try(var.flow_logs_s3_kms_key_arn, "")
        sse_algorithm     = var.flow_logs_s3_sse_algorithm
      }
    }
  }

  lifecycle_rule = [
    {
      id      = "flow_logs_lifecycle_rule"
      enabled = true
      transition = [
        {
          days          = var.flow_logs_s3_transition_standard_ia
          storage_class = "STANDARD_IA"
          }, {
          days          = var.flow_logs_s3_transition_glacier
          storage_class = "GLACIER"
        }
      ]
      expiration = {
        days                         = var.flow_logs_s3_expiration
        expired_object_delete_marker = false
      }

      noncurrent_version_expiration = {
        newer_noncurrent_versions = 5
        days                      = var.flow_logs_s3_non_current_expiration
      }
    }
  ]

  tags = {
    Name = local.flow_logs_bucket
  }
}

############################
# VPC ENDPOINTS
############################

module "vpc_endpoints" {
  source  = "terraform-aws-modules/vpc/aws//modules/vpc-endpoints"
  version = "5.4.0"

  vpc_id             = module.vpc.vpc_id
  security_group_ids = local.vpc_interface_endpoints_security_group_ids
  subnet_ids         = local.vpc_endpoint_default_subnet_ids

  endpoints = local.vpc_endpoints

  tags = {}
}

resource "aws_security_group" "vpc_interface_endpoints" {
  count       = local.create_vpc_interface_endpoint_security_group ? 1 : 0
  name        = local.vpc_interface_endpoint_sg_name
  description = "Security group para os VPC Endpoints de Interface da VPC ${local.vpc_name}"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "Permite trafego HTTPS para o VPC Endpoint"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = setunion([module.vpc.vpc_cidr_block], var.vpc_interface_endpoints_default_security_group.additional_cidr_blocks)
  }

  ingress {
    description = "All traffic para todo o proprio security group"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    self        = true
  }

  tags = {
    Name = local.vpc_interface_endpoint_sg_name
  }
}

############################
# SUBNET GROUP
############################

resource "aws_db_subnet_group" "this" {
  count = local.create_db_subnet_group

  name        = local.db_subnet_group.name
  description = "Subnet group de database da VPC ${local.vpc_name}"
  subnet_ids  = local.db_subnet_group.subnets

  tags = {
    Name = local.db_subnet_group.name
  }
}


################################################################################
# Customer Gateways
################################################################################

resource "aws_customer_gateway" "this" {
  for_each = var.customer_gateways

  bgp_asn     = each.value["bgp_asn"]
  ip_address  = each.value["ip_address"]
  device_name = lookup(each.value, "device_name", null)
  type        = "ipsec.1"

  tags = merge(
    { Name = "${var.name}-${each.key}" },
    var.tags,
    var.customer_gateway_tags,
  )

  lifecycle {
    create_before_destroy = true
  }
}

