# VPC #
output "vpc_id" {
  description = "O id da VPC."
  value       = module.vpc.vpc_id
}

output "vpc_cidr_block" {
  description = "CIDR Block da VPC."
  value       = module.vpc.vpc_cidr_block
}

output "vpc_enable_dns_support" {
  description = "Se a VPC tem ou não suporte a DNS."
  value       = module.vpc.vpc_enable_dns_support
}

output "vpc_enable_dns_hostnames" {
  description = "Se a VPC tem ou não suporte para hostname DNS."
  value       = module.vpc.vpc_enable_dns_hostnames
}

output "vpc_main_route_table_id" {
  description = "O id da main route table associada com a VPC."
  value       = module.vpc.vpc_main_route_table_id
}

output "vpc_secondary_cidr_blocks" {
  description = "Lista de blocos CIDR secundários da VPC"
  value       = module.vpc.vpc_secondary_cidr_blocks
}

# Internet Gateway #
output "igw_id" {
  description = "O ID do Internet Gateway."
  value       = module.vpc.igw_id
}

# Subnets Privadas #

output "private_subnets" {
  description = "Lista de IDs das subnets privadas"
  value       = local.outputs_private_subnets.subnets
}

output "private_subnets_cidr_blocks" {
  description = "Lista de blocos CIDR das subnets privadas"
  value       = local.outputs_private_subnets.cidr_blocks
}

output "private_route_table_ids" {
  description = "Lista de IDs das tabelas de rotas privadas"
  value       = local.outputs_private_subnets.route_table_ids
}

output "private_nat_gateway_route_ids" {
  description = "Lista de IDs das rotas de NAT Gateway privadas"
  value       = module.vpc.private_nat_gateway_route_ids
}

output "private_route_table_association_ids" {
  description = "Lista de IDs das associações de tabelas de rotas privadas"
  value       = local.outputs_private_subnets.route_table_association_ids
}

# Subnets Públicas #

output "public_subnets" {
  description = "Lista de IDs das subnets públicas"
  value       = module.vpc.public_subnets
}

output "public_subnets_cidr_blocks" {
  description = "Lista de blocos CIDR das subnets públicas"
  value       = module.vpc.public_subnets_cidr_blocks
}

output "public_route_table_ids" {
  description = "Lista de IDs das tabelas de rotas públicas"
  value       = module.vpc.public_route_table_ids
}

output "public_internet_gateway_route_id" {
  description = "ID da rota do Internet Gateway público"
  value       = module.vpc.public_internet_gateway_route_id
}

output "public_route_table_association_ids" {
  description = "Lista de IDs das associações de tabelas de rotas públicas"
  value       = module.vpc.public_route_table_association_ids
}

# database subnets #

output "database_subnets" {
  description = "Lista de IDs das database subnets"
  value       = module.vpc.database_subnets
}

output "database_subnets_cidr_blocks" {
  description = "Lista de blocos CIDR das database subnets"
  value       = module.vpc.database_subnets_cidr_blocks
}

output "database_subnet_group" {
  description = "ID do database subnet group."
  value       = module.vpc.database_subnet_group
}

output "database_route_table_ids" {
  description = "Lista de IDs das tabelas de rotas das database subnets."
  value       = module.vpc.database_route_table_ids
}

# Gateway NAT #

output "nat_ids" {
  description = "Lista de IDs de alocação de Elastic IPs criados para o AWS NAT Gateway"
  value       = module.vpc.nat_ids
}

output "nat_public_ips" {
  description = "Lista de Elastic IPs públicos criados para o AWS NAT Gateway."
  value       = module.vpc.nat_public_ips
}

output "natgw_ids" {
  description = "Lista de IDs do AWS NAT Gateway."
  value       = module.vpc.natgw_ids
}

# Log de Fluxo da VPC #

output "vpc_flow_log_id" {
  description = "O ID do recurso VPC Flow Logs."
  value       = module.vpc.vpc_flow_log_id
}

output "vpc_flow_log_destination_type" {
  description = "O tipo de destino para o VPC Flow Logs."
  value       = module.vpc.vpc_flow_log_destination_type
}

# Pontos de Extremidade da VPC - Interface + Gateway
output "endpoints" {
  description = "Um map dos endpoints da VPC contendo suas propriedades e configurações."
  value       = module.vpc_endpoints.endpoints
}

# Grupo de Segurança Padrão #

output "default_security_group_id" {
  description = "O ID do grupo de segurança criado por padrão na criação da VPC"
  value       = module.vpc.default_security_group_id
}
