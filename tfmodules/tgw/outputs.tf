output "transit_gateway_arn" {
  description = "O nome do recurso Amazon (ARN) do EC2 Transit Gateway"
  value       = module.tgw_core.ec2_transit_gateway_arn
}

output "transit_gateway_id" {
  description = "O identificador do EC2 Transit Gateway"
  value       = module.tgw_core.ec2_transit_gateway_id
}

output "transit_gateway_association_default_route_table_id" {
  description = "O identificador da route table association default"
  value       = module.tgw_core.ec2_transit_gateway_association_default_route_table_id
}

output "transit_gateway_propagation_default_route_table_id" {
  description = "O identificador da route table propagation default"
  value       = module.tgw_core.ec2_transit_gateway_propagation_default_route_table_id
}

output "transit_gateway_route_table_default_association_route_table" {
  description = "Um valor booleano que indica se esta é a route table association default para o EC2 Transit Gateway"
  value       = module.tgw_core.ec2_transit_gateway_route_table_default_association_route_table
}

output "transit_gateway_route_table_default_propagation_route_table" {
  description = "Um valor booleano que indica se esta é a route table propagation default para o EC2 Transit Gateway"
  value       = module.tgw_core.ec2_transit_gateway_route_table_default_propagation_route_table
}

output "transit_gateway_route_table_id" {
  description = "O identificador da route table do EC2 Transit Gateway"
  value       = module.tgw_core.ec2_transit_gateway_route_table_id
}

output "ram_principal_association_id" {
  description = "O nome do recurso Amazon (ARN) RAM Resource Share e do principal, separados por uma vírgula"
  value       = module.tgw_core.ram_principal_association_id
}

output "ram_resource_share_id" {
  description = "O nome do recurso Amazon (ARN) RAM Resource Share"
  value       = module.tgw_core.ram_resource_share_id
}