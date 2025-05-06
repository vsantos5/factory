variable "env" {
  type    = string
  default = "net"
}

variable "repository_name" {
  default = "null"
}

variable "name" {
  type    = string
}

variable "amazon_side_asn" {
  description = "ASN AWS para o Transit Gateway. Valores permitidos: 64512 a 65534 (ASNs 16-bit - mais utilizado) e 4200000000 a 4294967294 (ASNs 32-bit) ."
  type        = number

  validation {
    condition     = (var.amazon_side_asn >= 64512 && var.amazon_side_asn <= 65534) || (var.amazon_side_asn >= 4200000000 && var.amazon_side_asn <= 4294967294)
    error_message = "ASN invalido. Valores permitidos: 64512 a 65534 (ASNs 16-bit) e 4200000000 a 4294967294 (ASNs 32-bit) ."
  }
}

variable "tgw_name" {
  description = "Nome do Transit Gateway."
  type        = string
}

variable "tgw_route_table_name" {
  description = "Nome da Route Table do Transit Gateway criada pelo módulo."
  type        = string
  default     = "main"
}

variable "tgw_default_route_table_name" {
  description = "Nome da Route Table do Transit Gateway criada pela API da AWS."
  type        = string
  default     = "default"
}

variable "enable_multicast_support" {
  description = "Habilita multicast no Transit Gateway"
  type        = bool
  default     = false
}

variable "enable_dns_support" {
  description = "Habilita resolução DNS no Transit Gateway"
  type        = bool
  default     = true
}

variable "enable_vpn_ecmp_support" {
  description = "Habilita VPN ECMP no Transit Gateway"
  type        = string
  default     = true
}

variable "enable_default_route_table_association" {
  description = "**[CUIDADO, CONFIGURAÇÃO RECRIA O TRANSIT GATEWAY APÓS MODIFICADA]** Habilita a association dos attachments criados com uma TGW Route Table configurada como default."
  type        = string
  default     = true
}

variable "enable_default_route_table_propagation" {
  description = "**[CUIDADO, CONFIGURAÇÃO RECRIA O TRANSIT GATEWAY APÓS MODIFICADA]** Habilita a propagation dos attachments em uma TGW Route Table configurada como default."
  type        = string
  default     = true
}

variable "transit_gateway_cidr_blocks" {
  description = "CIDR blocks para Transit Gateway"
  type        = list(string)
  default     = []
}

variable "enable_auto_accept_shared_attachments" {
  description = "Determina se os attachments criados nas contas em que o Transit Gateway está compartilhado via RAM serão aceitos automaticamente."
  type        = bool
  default     = false
}

variable "enable_share_tgw" {
  description = "Se deseja compartilhar Transit Gateway com outras contas"
  type        = bool
  default     = false
}

variable "enable_share_tgw_with_all_organization" {
  description = "Se deseja compartilhar Transit Gateway com toda a organization."
  type        = bool
  default     = true
}

variable "enable_ram_allow_external_principals" {
  description = "Indica se os principals (ID das contas) fora da sua organização podem ser associados a um recursos compartilhado."
  type        = bool
  default     = false
}

variable "ram_principals" {
  description = "Uma lista de principals (ID das contas) com quem compartilhar o Transit Gateway. Os valores possíveis são um ID de conta da AWS ou AWS Organizations Organization Unit ARN."
  type        = list(string)
  default     = []
}

variable "description" {
  description = "Descrição do Transit Gateway"
  type        = string
  default     = null
}

variable "tgw_tags" {
  description = "Tags para o Transit Gateway"
  type        = map(string)
  default     = {}

  validation {
    condition     = try(var.tgw_tags.Name, "") == ""
    error_message = "Não colocar tag Name. Use a variavel tgw_name."
  }
}

variable "tgw_route_table_tags" {
  description = "Tags para o Transit Gateway"
  type        = map(string)
  default     = {}

  validation {
    condition     = try(var.tgw_route_table_tags.Name, "") == ""
    error_message = "Não colocar tag Name. Use a variavel tgw_rtb_name."
  }
}

variable "tgw_default_route_table_tags" {
  description = "Tags para a Transit Gateway"
  type        = map(string)
  default     = {}

  validation {
    condition     = try(var.tgw_default_route_table_tags.Name, "") == ""
    error_message = "Não colocar tag Name. Use a variavel tgw_rtb_name."
  }
}

variable "tgw_attachment_vpc_accepters" {
  description = <<EOF
  Map de attachments de VPC criados em outras contas para serem aceitos. Necessário estar com a variável `enable_auto_accept_shared_attachments` habilitada.
  Favor ler o README, pois essa variável possui alguns comportamentos destrutivos em relação aos TGW Attachments.
  
  Exemplo:
    {
      vpc-1 = "tgw-attach-1234",
      vpc-2 = "tgw-attach-5678"
    }
  EOF
  type        = map(string)
  default     = {}
}

variable "tags" {
  description = "Tags para todos os recursos do módulo"
  type        = map(string)
  default     = {}
}
