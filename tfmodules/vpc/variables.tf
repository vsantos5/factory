variable "vpc_name" {
  description = "Nome da VPC (valor da tag Name)"
  type        = string
}

variable "name" {
  description = "Nome padrão para todos os recursos"
  type        = string
  default     = ""
}

variable "vpc_tags" {
  description = "Tags para a VPC. Favor não incluir a tag Name"
  type        = map(string)
  default     = null

  validation {
    condition     = try(var.vpc_tags.Name, "") == ""
    error_message = "Não colocar tag Name. Use a variavel vpc_name."
  }
}

variable "default_security_group_tags" {
  description = "Tags para o SG default. Favor não incluir a tag Name"
  type        = map(string)
  default     = null

  validation {
    condition     = try(var.default_security_group_tags.Name, "") == ""
    error_message = "Não colocar tag Name. O nome sempre será default."
  }
}

variable "azs" {
  description = "Zonas de Disponibilidade que serão criados as Subnets"
  type        = set(string)
  default     = ["a", "b", "c"]
  validation {
    condition     = length(compact(var.azs)) >= 3
    error_message = "O mínimo são três zonas de disponibilidade distintas."
  }
}

variable "vpc_cidr" {
  description = "CIDR da VPC"
  type        = string
}

variable "vpc_secondary_cidr_blocks" {
  description = "Blocos CIDRs secindários para a VPC"
  type        = list(string)
  default     = []
}

variable "map_public_ip_on_launch" {
  description = "Determina se os recursos provisionados na subnet pública terão um IP associado automaticamente."
  type        = bool
  default     = true
}

variable "one_nat_gateway_per_az" {
  description = "Um NAT Gateway por AZ"
  type        = bool
  default     = true
}

variable "nat_gw_name" {
  description = "Nome do NAT Gateway"
  type        = string
  default     = null
}

variable "nat_eip_name" {
  description = "Nome do Elastic IP do NAT Gateway"
  type        = string
  default     = null
}

variable "tags" {
  description = "Tags para todos os recursos do módulo"
  type        = map(any)
  default     = null
}

variable "create_database_subnet" {
  description = "Indica se as subnets de database devem ser criadas"
  type        = bool
  default     = false
}

variable "database_subnets" {
  description = "Subnets de banco de dados a serem criadas. Informar no mínimo três"
  type        = list(string)
  default     = ["10.0.13.0/24", "10.0.14.0/24", "10.0.15.0/24"]

  validation {
    condition     = length(var.database_subnets) >= 3
    error_message = "O mínimo são três subnets."
  }
}
variable "database_acl_name" {
  description = "Nome das NACLs das subnets de banco de dados."
  type        = string
  default     = null
}

variable "database_inbound_acl_rules" {
  description = "Regras de entrada para NACLs das subnets de banco de dados."
  type        = list(map(string))
  default     = [{ "cidr_block" : "0.0.0.0/0", "from_port" : 0, "protocol" : "-1", "rule_action" : "allow", "rule_number" : 100, "to_port" : 0 }]
}
variable "database_outbound_acl_rules" {
  description = "Regras de saida para NACLs das subnets de banco de dados."
  type        = list(map(string))
  default     = [{ "cidr_block" : "0.0.0.0/0", "from_port" : 0, "protocol" : "-1", "rule_action" : "allow", "rule_number" : 100, "to_port" : 0 }]
}
variable "database_dedicated_network_acl" {
  description = "Regra para ativar NACLs dedicadas para subnets de banco de dados."
  type        = bool
  default     = false
}

################## INICIO SUBNET PUBLIC ##################
variable "public_subnets" {
  description = "Subnets publicas a serem criadas. Informar no mínimo três"
  type        = list(string)

  validation {
    condition     = length(var.public_subnets) >= 3
    error_message = "O mínimo são três subnets."
  }
}
variable "public_subnet_name" {
  description = "Nome sufixo atribuido para Subnets publicas."
  type        = string
  default     = null
}

variable "public_subnet_tags" {
  description = "Tags Adicionais para Subnets publicas a serem criadas."
  type        = map(string)
  default     = null
  validation {
    condition     = try(var.public_subnet_tags.Name, "") == ""
    error_message = "Não colocar tag Name. Usar a variável 'public_subnet_name'."
  }
}

variable "public_route_table_name" {
  description = "Nome sufixo atribuido para Route Table de Subnets publicas."
  type        = string
  default     = null
}


variable "igw_name" {
  description = "Nome do Internet Gateway"
  type        = string
  default     = null
}

variable "public_acl_name" {
  description = "Nome das NACLs das subnets públicas."
  type        = string
  default     = null
}

variable "public_inbound_acl_rules" {
  description = "Regras de entrada para NACLs das subnets públicas."
  type        = list(map(string))
  default     = [{ "cidr_block" : "0.0.0.0/0", "from_port" : 0, "protocol" : "-1", "rule_action" : "allow", "rule_number" : 100, "to_port" : 0 }]
}
variable "public_outbound_acl_rules" {
  description = "Regras de saida para NACLs das subnets públicas."
  type        = list(map(string))
  default     = [{ "cidr_block" : "0.0.0.0/0", "from_port" : 0, "protocol" : "-1", "rule_action" : "allow", "rule_number" : 100, "to_port" : 0 }]
}
variable "public_dedicated_network_acl" {
  description = "Regra para ativar NACLs dedicadas para subnets públicas."
  type        = bool
  default     = false
}


################## FIM SUBNET PUBLIC ##################


variable "private_subnets" {
  description = "Subnets privadas a serem criadas. Informar no mínimo três."
  type        = list(string)

  validation {
    condition     = length(var.private_subnets) >= 3
    error_message = "O mínimo são três subnets."
  }
}

variable "private_subnet_name" {
  description = "Nome sufixo aplicado nas subnets privadas, tanto classicas quando intra."
  type        = string
  default     = null
}

variable "private_acl_name" {
  description = "Nome das NACLs das subnets privadas."
  type        = string
  default     = null
}

variable "private_inbound_acl_rules" {
  description = "Regras de entrada para NACLs das subnets privadas."
  type        = list(map(string))
  default     = [{ "cidr_block" : "0.0.0.0/0", "from_port" : 0, "protocol" : "-1", "rule_action" : "allow", "rule_number" : 100, "to_port" : 0 }]
}
variable "private_outbound_acl_rules" {
  description = "Regras de saida para NACLs das subnets privadas."
  type        = list(map(string))
  default     = [{ "cidr_block" : "0.0.0.0/0", "from_port" : 0, "protocol" : "-1", "rule_action" : "allow", "rule_number" : 100, "to_port" : 0 }]
}
variable "private_dedicated_network_acl" {
  description = "Regra para ativar NACLs dedicadas para subnets privadas."
  type        = bool
  default     = false
}

variable "default_route_table_name" {
  description = "Nome da Route Table default"
  type        = string
  default     = null
}

variable "default_nacl_name" {
  description = "Nome da NACL default"
  type        = string
  default     = null
}

variable "dhcp_options_name" {
  description = "Nome sufixo para o DHCP options."
  type        = string
  default     = null
}

variable "create_database_subnet_group" {
  description = "Determina se o subnet group de database será criado."
  type        = bool
  default     = true
}

variable "db_subnet_group_name" {
  description = "Nome sufixo para o subnet group de database."
  type        = string
  default     = null
}

variable "classic_private_subnets" {
  description = "Defina como 'true' para criar subnets privadas com rota para Nat Gateway. Defina como 'false' para criar subnets privadas no modelo Intra, sem rota para Nat Gateway."
  type        = bool
  default     = true
}

variable "private_route_table_name" {
  description = "Nome sufixo que será atribuido à route table das subnets privadas"
  type        = string
  default     = null
}

variable "flow_logs_name" {
  description = "Nome para identificar o recurso Flow Logs."
  type        = string
  default     = null
}

variable "private_subnet_tags" {
  description = "Tags customizadas para as subnets privadas clássicas."
  type        = map(string)
  default     = null

  validation {
    condition     = try(var.private_subnet_tags.Name, "") == ""
    error_message = "Não colocar tag Name. Usar a variável 'private_subnet_name'."
  }
}

variable "flow_logs_s3_bucket_name" {
  description = "Nome do bucket criado para o recurso Flow Logs."
  type        = string
  default     = null
}

variable "enable_flow_logs" {
  description = "Flag para habilitar(true-default) ou desabilitar(false) o flow log na VPC."
  type        = bool
  default     = true
}

variable "flow_logs_s3_use_existing_bucket" {
  description = "Flag para informar se sera utilizado um bucket existente(true) ou será criado um bucket novo para armazenar os dados do Flow Logs(false=default)."
  type        = bool
  default     = false
}

variable "flow_logs_s3_existing_bucket_arn" {
  description = "ARN do bucket que sera utilizado para armazenar os dados do Flow Logs."
  type        = string
  default     = null
}

variable "flow_logs_s3_force_destroy" {
  description = "Determina se o bucket do Flow Logs criado pelo módulo poderá ser apagado mesmo com arquivos dentro."
  type        = string
  default     = false
}

variable "database_route_table_name" {
  description = "Nome sufixo que será atribuido à route table das subnets de banco de dados"
  type        = string
  default     = null
}

variable "flow_logs_s3_transition_standard_ia" {
  description = "Periodo em dias para mover os objetos para a classe S3 Standard IA, no bucket do Flow Logs criado pelo modulo."
  type        = number
  default     = 30
}

variable "flow_logs_s3_transition_glacier" {
  description = "Periodo em dias para mover os objetos para a classe S3 Glacier, no bucket do Flow Logs criado pelo modulo."
  type        = number
  default     = 60
}

variable "flow_logs_s3_expiration" {
  description = "Periodo em dias para expirar os logs no bucket do Flow Logs criado pelo modulo. Para desabilitar utilize o valor null."
  type        = number
  default     = 1825
}

variable "flow_logs_s3_non_current_expiration" {
  description = "Periodo em dias para expirar as versões antigas dos logs, no bucket do Flow Logs criado pelo modulo."
  type        = number
  default     = 30
}

variable "flow_logs_s3_kms_key_arn" {
  description = "(Opcional)ARN da Chave KMS utilizada para cirptografar o bucket do Flow Logs criado pelo modulo. Essa informacao so precisa ser utilizada quando o sse_algorithm for aws:kms. Por padrao, a chave utilizada sera aws/s3."
  type        = string
  default     = ""
}

variable "flow_logs_s3_sse_algorithm" {
  description = "Algoritimo utilizado para criptografar os dados do bucket do Flow Logs criado pelo modulo. Valores validos: AES256 ou aws:kms"
  type        = string
  default     = "AES256"
}

variable "flow_logs_s3_versioning" {
  description = "Flag para informar se o versionamento deve ser habilitado(true=default) para o bucket do Flow Logs criado pelo modulo."
  type        = bool
  default     = true
}

variable "database_subnet_name" {
  description = "Nome sufixo que será atribuido à route table das subnets de banco de dados"
  type        = string
  default     = null
}

variable "vpc_interface_endpoints" {
  description = <<EOF
  
  Possibilita a criação de VPC Endpoints de Interface de forma dinâmica. 
  
  Favor ler descrição da variável `vpc_interface_endpoint_default_security_group` e `vpc_interface_endpoints_default_subnets` .

  A chave de cada map é o domínio do serviço com.amazonaws.region.<nome_do_serviço>
  Exemplo:
  {
  "lambda" = {
    private_dns_enabled = false,
    default_policy      = true,
    custom_policy       = null,
    subnet              = "private"
    security_group_ids  = []
  },
  "ecr.dkr" = {
    private_dns_enabled = true,
    default_policy      = true,
    custom_policy       = null,
    subnet              = "public"
    security_group_ids  = []
  }
}

Para saber os nomes de todos os serviços que se integram com o VPC Endpint de Interface (AWS Private Link), acesse [Doc AWS - Serviços Suportados PrivateLink](https://docs.aws.amazon.com/vpc/latest/privatelink/aws-services-privatelink-support.html)
EOF

  type = map(object({
    private_dns_enabled = bool,
    default_policy      = bool,
    custom_policy       = string,
    subnet              = string
    security_group_ids  = list(string)
  }))
  default = {}

  validation {
    condition     = !contains([for k, v in var.vpc_interface_endpoints : false if !contains(["private", "database", "public", null], v.subnet)], false)
    error_message = "Escopo de subnet inválido. Corrija o parâmetro `subnet` dos endpoints de interface."
  }
}

variable "vpc_interface_endpoints_name" {
  description = "Nome sufixo que será atribuido aos VPC Endpoints de Interface."
  type        = string
  default     = null
}

variable "vpc_interface_endpoints_default_subnets" {
  description = <<EOF
  Escopo de subnets para todos os VPC Endpoints de interface. Deixar undefined caso queira ir escolhendo caso a caso via variável `vpc_interface_endpoints` . 
  Se o valor estiver diferente de `undefined`, o parâmetro `subnet` de `vpc_interface_endpoints` será completamente ignorado.
  EOF

  type    = string
  default = "undefined"

  validation {
    condition     = contains(["private", "database", "public", "undefined"], var.vpc_interface_endpoints_default_subnets)
    error_message = "Escopo de subnet inválido. Valores válidos: `private` , `database` , `public`, `undefined' . Não preencha a variável caso não queria declará-la."
  }
}

variable "vpc_interface_endpoints_default_security_group" {
  description = <<EOF
  Favor decidir o valor dessa variável antes de criar os VPC Endpoints de Interface em `vpc_interface_endpoints` .
  
  Define um security group default para todos os VPC Endpoints de Interface. 
  Esse security group libera por padrão a porta 443 para o CIDR da VPC e All Traffic para o próprio Security Group.  
  EOF

  type = object({
    create                 = bool
    name                   = string
    additional_cidr_blocks = list(string)
  })
  default = {
    create                 = false
    name                   = null
    additional_cidr_blocks = []
  }
}

variable "vpc_gateways_endpoint_name" {
  description = "Nome sufixo que será atribuido aos VPC Endpoints de Gateway."
  type        = string
  default     = null
}

variable "create_vpc_gateway_endpoints" {
  description = "Determina a criação dos VPC Endpoints de Gateway - S3 e DynamoDB."
  type        = bool
  default     = true
}

variable "vpc_gateway_endpoints_rtb" {
  description = "Escopo de route tables para todos os VPC Endpoints de Gateway."
  type        = list(string)
  default     = ["private"]

  validation {
    condition     = !contains([for i in var.vpc_gateway_endpoints_rtb : false if !contains(["private", "database", "public"], i)], false)
    error_message = "Escopo de route table inválido. Valores válidos: `private` , `database` , `public` ."
  }
}


################################################################################
# Customer Gateways
################################################################################

variable "customer_gateways" {
  description = "Maps of Customer Gateway's attributes (BGP ASN and Gateway's Internet-routable external IP address)"
  type        = map(map(any))
  default     = {}
}

variable "customer_gateway_tags" {
  description = "Additional tags for the Customer Gateway"
  type        = map(string)
  default     = {}
}

################################################################################
# VPN Gateway
################################################################################

variable "enable_vpn_gateway" {
  description = "Should be true if you want to create a new VPN Gateway resource and attach it to the VPC"
  type        = bool
  default     = false
}

variable "vpn_gateway_id" {
  description = "ID of VPN Gateway to attach to the VPC"
  type        = string
  default     = ""
}

variable "amazon_side_asn" {
  description = "The Autonomous System Number (ASN) for the Amazon side of the gateway. By default the virtual private gateway is created with the current default Amazon ASN"
  type        = string
  default     = "64512"
}

variable "vpn_gateway_az" {
  description = "The Availability Zone for the VPN Gateway"
  type        = string
  default     = null
}

variable "propagate_intra_route_tables_vgw" {
  description = "Should be true if you want route table propagation"
  type        = bool
  default     = false
}

variable "propagate_private_route_tables_vgw" {
  description = "Should be true if you want route table propagation"
  type        = bool
  default     = false
}

variable "propagate_public_route_tables_vgw" {
  description = "Should be true if you want route table propagation"
  type        = bool
  default     = false
}

variable "vpn_gateway_tags" {
  description = "Additional tags for the VPN gateway"
  type        = map(string)
  default     = {}
}