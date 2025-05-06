locals {
  region = "us-east-2"

  azs = [for i in var.azs : "${data.aws_region.this.name}${i}"]

  vpc_name = "vpc-${coalesce(var.name, var.vpc_name, "DEFAULT")}"

  default_route_table_name = "rtb-${coalesce(var.name, var.default_route_table_name, "DEFAULT")}-default"

  default_nacl_name = "nacl-${coalesce(var.name, var.default_nacl_name, "DEFAULT")}-default"

  dhcp_options_name = "dhcp-options-${coalesce(var.name, var.dhcp_options_name, "DEFAULT")}"

  nat_gw_name = "nat-gw-${coalesce(var.name, var.nat_gw_name, "DEFAULT")}"

  nat_eip_name = "eip-${coalesce(var.name, var.nat_eip_name, "DEFAULT")}-nat-gw"

  private_route_table_name = (!var.classic_private_subnets && var.create_database_subnet && (var.one_nat_gateway_per_az || local.single_nat_gateway)) ? "do-not-use" : "rtb-${coalesce(var.name, var.private_route_table_name, "DEFAULT")}-private"

  intra_route_table_name = "rtb-${coalesce(var.name, var.private_route_table_name, "DEFAULT")}-private"

  private_subnet_names = [
    for subnet in range(length(var.private_subnets)) : "subnet-${coalesce(var.name, var.private_subnet_name, "DEFAULT")}-private-${element(local.azs, subnet)}"
  ]

  private_subnets = var.classic_private_subnets ? var.private_subnets : []

  intra_subnets = var.classic_private_subnets ? [] : var.private_subnets

  enable_nat_gateway = var.classic_private_subnets ? true : false

  one_nat_gateway_per_az = var.classic_private_subnets ? var.one_nat_gateway_per_az : false

  single_nat_gateway = (var.classic_private_subnets && var.create_database_subnet && var.one_nat_gateway_per_az) ? false : (var.classic_private_subnets && var.create_database_subnet && !var.one_nat_gateway_per_az) ? true : (!var.classic_private_subnets && var.create_database_subnet && var.one_nat_gateway_per_az) ? true : (!var.classic_private_subnets && var.create_database_subnet && !var.one_nat_gateway_per_az) ? true : (var.classic_private_subnets && !var.create_database_subnet && !var.one_nat_gateway_per_az) ? true : false

  flow_logs_bucket = "s3-vpc-flow-logs-${coalesce(var.name, var.flow_logs_s3_bucket_name, "default")}"

  flow_logs_name   = "vpc-flow-logs-${coalesce(var.name, var.flow_logs_name, "DEFAULT")}"
  database_subnets = var.create_database_subnet ? var.database_subnets : []

  database_route_table_name = "rtb-${coalesce(var.name, var.database_route_table_name, "DEFAULT")}-database"

  database_subnet_names = [
    for subnet in range(length(var.database_subnets)) : "subnet-${coalesce(var.name, var.database_subnet_name, "DEFAULT")}-database-${element(local.azs, subnet)}"
  ]
  public_route_table_name = "rtb-${coalesce(var.name, var.public_route_table_name, "DEFAULT")}-public"

  public_subnet_names = [
    for subnet in range(length(var.public_subnets)) : "subnet-${coalesce(var.name, var.public_subnet_name, "DEFAULT")}-public-${element(local.azs, subnet)}"
  ]

  igw_name = "igw-${coalesce(var.name, var.igw_name, "DEFAULT")}"

  flow_log_destination_arn = var.flow_logs_s3_use_existing_bucket ? var.flow_logs_s3_existing_bucket_arn : try(module.s3_bucket[0].s3_bucket_arn, "")

  create_flow_logs_bucket = !var.flow_logs_s3_use_existing_bucket && var.enable_flow_logs ? 1 : 0

  public_acl_name = "nacl-${coalesce(var.name, var.public_acl_name, "DEFAULT")}-public"

  private_acl_name = "nacl-${coalesce(var.name, var.private_acl_name, "DEFAULT")}-private"

  database_acl_name = "nacl-${coalesce(var.name, var.database_acl_name, "DEFAULT")}-database"



  # Lógica para coletar o maior número de subnets possível baseado na quantidade de AZs escolhidas
  # 3 azs = 3 subnets de database/private/public
  vpc_endpoint_aux_subnet_ids = {
    private  = try(slice(module.vpc.private_subnets, 0, length(var.azs)), []),
    intra    = try(slice(module.vpc.intra_subnets, 0, length(var.azs)), [])
    database = try(slice(module.vpc.database_subnets, 0, length(var.azs)), [])
    public   = slice(module.vpc.public_subnets, 0, length(var.azs))

  }

  vpc_endpoint_subnet_ids = {
    private  = flatten([local.vpc_endpoint_aux_subnet_ids.private, local.vpc_endpoint_aux_subnet_ids.intra])
    database = local.vpc_endpoint_aux_subnet_ids.database,
    public   = local.vpc_endpoint_aux_subnet_ids.public
  }

  vpc_endpoint_default_subnet_ids = var.vpc_interface_endpoints_default_subnets != "undefined" ? local.vpc_endpoint_subnet_ids[var.vpc_interface_endpoints_default_subnets] : []
  ############################
  # VPC ENDPOINTS - INTERFACE
  ############################
  vpc_interface_endpoints = {
    for k, v in var.vpc_interface_endpoints :
    k => {
      service             = k
      private_dns_enabled = v.private_dns_enabled,
      policy              = v.default_policy ? data.aws_iam_policy_document.default_endpoint_policy[0].json : v.custom_policy
      subnet_ids          = length(local.vpc_endpoint_default_subnet_ids) > 0 ? local.vpc_endpoint_default_subnet_ids : local.vpc_endpoint_subnet_ids[v.subnet]
      security_group_ids  = v.security_group_ids
      tags = {
        Name = "vpce-${replace(k, ".", "-")}-${coalesce(var.name, var.vpc_interface_endpoints_name, "DEFAULT")}-interface"
      }
    }
  }

  vpc_interface_endpoints_security_group_ids = compact([try(aws_security_group.vpc_interface_endpoints[0].id, ""), module.vpc.default_security_group_id])

  ############################
  # VPC ENDPOINTS - GATEWAY
  ############################
  vpc_endpoint_rtb_ids = {
    private  = var.classic_private_subnets ? module.vpc.private_route_table_ids : module.vpc.intra_route_table_ids
    database = module.vpc.database_route_table_ids
    public   = module.vpc.public_route_table_ids
  }

  vpc_gateway_endpoints_rtb = flatten([for i in var.vpc_gateway_endpoints_rtb : local.vpc_endpoint_rtb_ids[i]])

  vpc_gateway_endpoints = var.create_vpc_gateway_endpoints ? {

    s3 = {
      service         = "s3"
      service_type    = "Gateway"
      route_table_ids = local.vpc_gateway_endpoints_rtb
      policy          = data.aws_iam_policy_document.default_endpoint_policy[0].json
      tags = {
        Name = "vpce-s3-${coalesce(var.name, var.vpc_gateways_endpoint_name, "DEFAULT")}-gateway"
      }
    },
    dynamodb = {
      service         = "dynamodb"
      service_type    = "Gateway"
      route_table_ids = local.vpc_gateway_endpoints_rtb
      policy          = data.aws_iam_policy_document.default_endpoint_policy[0].json
      tags = {
        Name = "vpce-dynamodb-${coalesce(var.name, var.vpc_gateways_endpoint_name, "DEFAULT")}-gateway"
      }
    }
  } : {}

  ############################
  # VPC ENDPOINTS - MERGE
  ############################
  vpc_endpoints = merge(local.vpc_gateway_endpoints, local.vpc_interface_endpoints)


  create_vpc_interface_endpoint_security_group = var.vpc_interface_endpoints != {} && var.vpc_interface_endpoints_default_security_group.create
  vpc_interface_endpoint_sg_name               = "SG-vpc-endpoint-interface-${coalesce(var.name, var.vpc_interface_endpoints_default_security_group.name, "DEFAULT")}"

  ############################
  # SUBNET GROUP
  ############################
  create_db_subnet_group = var.create_database_subnet_group ? 1 : 0
  db_subnet_group = {
    name    = "subnet-group-${coalesce(var.name, var.db_subnet_group_name, "default")}-database",
    subnets = var.create_database_subnet ? module.vpc.database_subnets : flatten([module.vpc.intra_subnets, module.vpc.private_subnets])
  }

  ############################
  # OUTPUTS - PRIVATE SUBNETS
  ############################
  outputs_private_subnets = {
    subnets                     = flatten([module.vpc.intra_subnets, module.vpc.private_subnets])
    cidr_blocks                 = flatten([module.vpc.intra_subnets_cidr_blocks, module.vpc.private_subnets_cidr_blocks])
    route_table_ids             = flatten([module.vpc.intra_route_table_ids, module.vpc.private_route_table_ids])
    route_table_association_ids = flatten([module.vpc.intra_route_table_association_ids, module.vpc.private_route_table_association_ids])
  }
}