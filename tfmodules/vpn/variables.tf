variable "vpc_name" {
  description = "Nome da VPC (valor da tag Name)"
  type        = string
}

variable "tgw_name" {
  description = "Nome do Transit Gateway (valor da tag Name)"
  type        = string
}

variable "cgw_name" {
  description = "Nome do Customer Gateway (valor da tag Name)"
  type        = string
}

variable "tags" {
  description = "Tags para todos os recursos do módulo"
  type        = map(string)
  default     = {}
}