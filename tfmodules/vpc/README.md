# terraform-aws-brlink-vpc
## Introdução
Esse módulo é responável por provisionar uma VPC e seus recursos relacionados.
O módulo provisiona os seguintes recursos:

- DHCP Options
- VPC
- Subnets
- Internet Gateway
- NAT Gateway
- Route Tables
- NACL
- VPC Flow Logs integrado com S3
- VPC Endpoints (Interface e Gateway)
- Subnet Group (RDS)

## Subnets - Escopos
Trabalhamos nesse módulo com 3 escopos de subnet:

- **Pública** (Obrigatória)
- **Privada**** (Obrigatória - Possui 2 variações)
- **Banco de Dados** (Opcional)

## Subnets Privadas - Variações
Existem 2 variações de subnets privadas, que para o usuário final do módulo é basicamente um `true` ou `false` .

- **Privada - Clássica** - Habilita a criação do NAT Gateway (podendo ser single, por default multi-az). Rota para a internet jogando para o NAT Gateway.
- **Privada - Intra** - Desabilita a criação do NAT Gateway. Rota local apenas. Útil para cenários onde a saída para a internet ocorre através de outra VPC.

A variável que define esses escopos é a `classic_private_subnets` .

## VPC Flow Logs
- Por padrão, o Server Side Encription do bucket criado para armazenar os Flow Logs, está utilizando a chave gerenciada da AWS (SSE/S3), caso precise utilizar uma chave SSE-KMS, será necessário acrescentar um Statement na policy da chave KMS, que está associada ao bucket, conforme o modelo abaixo:

```json
        {
            "Sid": "Allow VPC Flow Logs to use the key",
            "Effect": "Allow",
            "Principal": {
                "Service": "delivery.logs.amazonaws.com"
            },
            "Action": [
                "kms:ReEncrypt",
                "kms:GenerateDataKey",
                "kms:Encrypt",
                "kms:DescribeKey",
                "kms:Decrypt"
            ],
            "Resource": "*"
        }
```

## Uso

```hcl
module "vpc" {
  source = "git::git@bitbucket.org:safepag/aws-infra/v2/tfmodules/vpc.git?"

  vpc_cidr                     = "10.0.0.0/16"
  name                         = "projeto-saturno"
  vpc_name                     = "projeto-saturno-network"
  # Por default é 1 NAT GW por AZ (Deixar true sempre em PRD)
  one_nat_gateway_per_az       = false
  public_subnets               = ["10.0.0.0/24", "10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  private_subnets              = ["10.0.10.0/24", "10.0.11.0/24", "10.0.12.0/24", "10.0.13.0/24"]
}
```

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.1.5 |
| aws | >= 5.0.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| s3\_bucket | terraform-aws-modules/s3-bucket/aws | 3.10.1 |
| vpc | terraform-aws-modules/vpc/aws | 5.4.0 |
| vpc\_endpoints | terraform-aws-modules/vpc/aws//modules/vpc-endpoints | 5.4.0 |

## Resources

| Name | Type |
|------|------|
| [aws_db_subnet_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_subnet_group) | resource |
| [aws_security_group.vpc_interface_endpoints](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_iam_policy_document.default_endpoint_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_region.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| private\_subnets | Subnets privadas a serem criadas. Informar no mínimo três. | `list(string)` | n/a | yes |
| public\_subnets | Subnets publicas a serem criadas. Informar no mínimo três | `list(string)` | n/a | yes |
| vpc\_cidr | CIDR da VPC | `string` | n/a | yes |
| vpc\_name | Nome da VPC (valor da tag Name) | `string` | n/a | yes |
| azs | Zonas de Disponibilidade que serão criados as Subnets | `set(string)` | ```[ "a", "b", "c" ]``` | no |
| classic\_private\_subnets | Defina como 'true' para criar subnets privadas com rota para Nat Gateway. Defina como 'false' para criar subnets privadas no modelo Intra, sem rota para Nat Gateway. | `bool` | `true` | no |
| create\_database\_subnet | Indica se as subnets de database devem ser criadas | `bool` | `false` | no |
| create\_database\_subnet\_group | Determina se o subnet group de database será criado. | `bool` | `true` | no |
| create\_vpc\_gateway\_endpoints | Determina a criação dos VPC Endpoints de Gateway - S3 e DynamoDB. | `bool` | `true` | no |
| database\_acl\_name | Nome das NACLs das subnets de banco de dados. | `string` | `null` | no |
| database\_dedicated\_network\_acl | Regra para ativar NACLs dedicadas para subnets de banco de dados. | `bool` | `false` | no |
| database\_inbound\_acl\_rules | Regras de entrada para NACLs das subnets de banco de dados. | `list(map(string))` | ```[ { "cidr_block": "0.0.0.0/0", "from_port": 0, "protocol": "-1", "rule_action": "allow", "rule_number": 100, "to_port": 0 } ]``` | no |
| database\_outbound\_acl\_rules | Regras de saida para NACLs das subnets de banco de dados. | `list(map(string))` | ```[ { "cidr_block": "0.0.0.0/0", "from_port": 0, "protocol": "-1", "rule_action": "allow", "rule_number": 100, "to_port": 0 } ]``` | no |
| database\_route\_table\_name | Nome sufixo que será atribuido à route table das subnets de banco de dados | `string` | `null` | no |
| database\_subnet\_name | Nome sufixo que será atribuido à route table das subnets de banco de dados | `string` | `null` | no |
| database\_subnets | Subnets de banco de dados a serem criadas. Informar no mínimo três | `list(string)` | ```[ "10.0.13.0/24", "10.0.14.0/24", "10.0.15.0/24" ]``` | no |
| db\_subnet\_group\_name | Nome sufixo para o subnet group de database. | `string` | `null` | no |
| default\_nacl\_name | Nome da NACL default | `string` | `null` | no |
| default\_route\_table\_name | Nome da Route Table default | `string` | `null` | no |
| default\_security\_group\_tags | Tags para o SG default. Favor não incluir a tag Name | `map(string)` | `null` | no |
| dhcp\_options\_name | Nome sufixo para o DHCP options. | `string` | `null` | no |
| enable\_flow\_logs | Flag para habilitar(true-default) ou desabilitar(false) o flow log na VPC. | `bool` | `true` | no |
| flow\_logs\_name | Nome para identificar o recurso Flow Logs. | `string` | `null` | no |
| flow\_logs\_s3\_bucket\_name | Nome do bucket criado para o recurso Flow Logs. | `string` | `null` | no |
| flow\_logs\_s3\_existing\_bucket\_arn | ARN do bucket que sera utilizado para armazenar os dados do Flow Logs. | `string` | `null` | no |
| flow\_logs\_s3\_expiration | Periodo em dias para expirar os logs no bucket do Flow Logs criado pelo modulo. Para desabilitar utilize o valor null. | `number` | `1825` | no |
| flow\_logs\_s3\_force\_destroy | Determina se o bucket do Flow Logs criado pelo módulo poderá ser apagado mesmo com arquivos dentro. | `string` | `false` | no |
| flow\_logs\_s3\_kms\_key\_arn | (Opcional)ARN da Chave KMS utilizada para cirptografar o bucket do Flow Logs criado pelo modulo. Essa informacao so precisa ser utilizada quando o sse\_algorithm for aws:kms. Por padrao, a chave utilizada sera aws/s3. | `string` | `""` | no |
| flow\_logs\_s3\_non\_current\_expiration | Periodo em dias para expirar as versões antigas dos logs, no bucket do Flow Logs criado pelo modulo. | `number` | `30` | no |
| flow\_logs\_s3\_sse\_algorithm | Algoritimo utilizado para criptografar os dados do bucket do Flow Logs criado pelo modulo. Valores validos: AES256 ou aws:kms | `string` | `"AES256"` | no |
| flow\_logs\_s3\_transition\_glacier | Periodo em dias para mover os objetos para a classe S3 Glacier, no bucket do Flow Logs criado pelo modulo. | `number` | `60` | no |
| flow\_logs\_s3\_transition\_standard\_ia | Periodo em dias para mover os objetos para a classe S3 Standard IA, no bucket do Flow Logs criado pelo modulo. | `number` | `30` | no |
| flow\_logs\_s3\_use\_existing\_bucket | Flag para informar se sera utilizado um bucket existente(true) ou será criado um bucket novo para armazenar os dados do Flow Logs(false=default). | `bool` | `false` | no |
| flow\_logs\_s3\_versioning | Flag para informar se o versionamento deve ser habilitado(true=default) para o bucket do Flow Logs criado pelo modulo. | `bool` | `true` | no |
| igw\_name | Nome do Internet Gateway | `string` | `null` | no |
| map\_public\_ip\_on\_launch | Determina se os recursos provisionados na subnet pública terão um IP associado automaticamente. | `bool` | `true` | no |
| name | Nome padrão para todos os recursos | `string` | `""` | no |
| nat\_eip\_name | Nome do Elastic IP do NAT Gateway | `string` | `null` | no |
| nat\_gw\_name | Nome do NAT Gateway | `string` | `null` | no |
| one\_nat\_gateway\_per\_az | Um NAT Gateway por AZ | `bool` | `true` | no |
| private\_acl\_name | Nome das NACLs das subnets privadas. | `string` | `null` | no |
| private\_dedicated\_network\_acl | Regra para ativar NACLs dedicadas para subnets privadas. | `bool` | `false` | no |
| private\_inbound\_acl\_rules | Regras de entrada para NACLs das subnets privadas. | `list(map(string))` | ```[ { "cidr_block": "0.0.0.0/0", "from_port": 0, "protocol": "-1", "rule_action": "allow", "rule_number": 100, "to_port": 0 } ]``` | no |
| private\_outbound\_acl\_rules | Regras de saida para NACLs das subnets privadas. | `list(map(string))` | ```[ { "cidr_block": "0.0.0.0/0", "from_port": 0, "protocol": "-1", "rule_action": "allow", "rule_number": 100, "to_port": 0 } ]``` | no |
| private\_route\_table\_name | Nome sufixo que será atribuido à route table das subnets privadas | `string` | `null` | no |
| private\_subnet\_name | Nome sufixo aplicado nas subnets privadas, tanto classicas quando intra. | `string` | `null` | no |
| private\_subnet\_tags | Tags customizadas para as subnets privadas clássicas. | `map(string)` | `null` | no |
| public\_acl\_name | Nome das NACLs das subnets públicas. | `string` | `null` | no |
| public\_dedicated\_network\_acl | Regra para ativar NACLs dedicadas para subnets públicas. | `bool` | `false` | no |
| public\_inbound\_acl\_rules | Regras de entrada para NACLs das subnets públicas. | `list(map(string))` | ```[ { "cidr_block": "0.0.0.0/0", "from_port": 0, "protocol": "-1", "rule_action": "allow", "rule_number": 100, "to_port": 0 } ]``` | no |
| public\_outbound\_acl\_rules | Regras de saida para NACLs das subnets públicas. | `list(map(string))` | ```[ { "cidr_block": "0.0.0.0/0", "from_port": 0, "protocol": "-1", "rule_action": "allow", "rule_number": 100, "to_port": 0 } ]``` | no |
| public\_route\_table\_name | Nome sufixo atribuido para Route Table de Subnets publicas. | `string` | `null` | no |
| public\_subnet\_name | Nome sufixo atribuido para Subnets publicas. | `string` | `null` | no |
| public\_subnet\_tags | Tags Adicionais para Subnets publicas a serem criadas. | `map(string)` | `null` | no |
| tags | Tags para todos os recursos do módulo | `map(any)` | `null` | no |
| vpc\_gateway\_endpoints\_rtb | Escopo de route tables para todos os VPC Endpoints de Gateway. | `list(string)` | ```[ "private" ]``` | no |
| vpc\_gateways\_endpoint\_name | Nome sufixo que será atribuido aos VPC Endpoints de Gateway. | `string` | `null` | no |
| vpc\_interface\_endpoints | Possibilita a criação de VPC Endpoints de Interface de forma dinâmica.     Favor ler descrição da variável `vpc_interface_endpoint_default_security_group` e `vpc_interface_endpoints_default_subnets` .    A chave de cada map é o domínio do serviço com.amazonaws.region.<nome\_do\_serviço>   Exemplo:   {   "lambda" = {     private\_dns\_enabled = false,     default\_policy      = true,     custom\_policy       = null,     subnet              = "private"     security\_group\_ids  = []   },   "ecr.dkr" = {     private\_dns\_enabled = true,     default\_policy      = true,     custom\_policy       = null,     subnet              = "public"     security\_group\_ids  = []   } }  Para saber os nomes de todos os serviços que se integram com o VPC Endpint de Interface (AWS Private Link), acesse [Doc AWS - Serviços Suportados PrivateLink](https://docs.aws.amazon.com/vpc/latest/privatelink/aws-services-privatelink-support.html) | ```map(object({ private_dns_enabled = bool, default_policy = bool, custom_policy = string, subnet = string security_group_ids = list(string) }))``` | `{}` | no |
| vpc\_interface\_endpoints\_default\_security\_group | Favor decidir o valor dessa variável antes de criar os VPC Endpoints de Interface em `vpc_interface_endpoints` .    Define um security group default para todos os VPC Endpoints de Interface.    Esse security group libera por padrão a porta 443 para o CIDR da VPC e All Traffic para o próprio Security Group. | ```object({ create = bool name = string additional_cidr_blocks = list(string) })``` | ```{ "additional_cidr_blocks": [], "create": false, "name": null }``` | no |
| vpc\_interface\_endpoints\_default\_subnets | Escopo de subnets para todos os VPC Endpoints de interface. Deixar undefined caso queira ir escolhendo caso a caso via variável `vpc_interface_endpoints` .    Se o valor estiver diferente de `undefined`, o parâmetro `subnet` de `vpc_interface_endpoints` será completamente ignorado. | `string` | `"undefined"` | no |
| vpc\_interface\_endpoints\_name | Nome sufixo que será atribuido aos VPC Endpoints de Interface. | `string` | `null` | no |
| vpc\_secondary\_cidr\_blocks | Blocos CIDRs secindários para a VPC | `list(string)` | `[]` | no |
| vpc\_tags | Tags para a VPC. Favor não incluir a tag Name | `map(string)` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| database\_route\_table\_ids | Lista de IDs das tabelas de rotas das database subnets. |
| database\_subnet\_group | ID do database subnet group. |
| database\_subnets | Lista de IDs das database subnets |
| database\_subnets\_cidr\_blocks | Lista de blocos CIDR das database subnets |
| default\_security\_group\_id | O ID do grupo de segurança criado por padrão na criação da VPC |
| endpoints | Um map dos endpoints da VPC contendo suas propriedades e configurações. |
| igw\_id | O ID do Internet Gateway. |
| nat\_ids | Lista de IDs de alocação de Elastic IPs criados para o AWS NAT Gateway |
| nat\_public\_ips | Lista de Elastic IPs públicos criados para o AWS NAT Gateway. |
| natgw\_ids | Lista de IDs do AWS NAT Gateway. |
| private\_nat\_gateway\_route\_ids | Lista de IDs das rotas de NAT Gateway privadas |
| private\_route\_table\_association\_ids | Lista de IDs das associações de tabelas de rotas privadas |
| private\_route\_table\_ids | Lista de IDs das tabelas de rotas privadas |
| private\_subnets | Lista de IDs das subnets privadas |
| private\_subnets\_cidr\_blocks | Lista de blocos CIDR das subnets privadas |
| public\_internet\_gateway\_route\_id | ID da rota do Internet Gateway público |
| public\_route\_table\_association\_ids | Lista de IDs das associações de tabelas de rotas públicas |
| public\_route\_table\_ids | Lista de IDs das tabelas de rotas públicas |
| public\_subnets | Lista de IDs das subnets públicas |
| public\_subnets\_cidr\_blocks | Lista de blocos CIDR das subnets públicas |
| vpc\_cidr\_block | CIDR Block da VPC. |
| vpc\_enable\_dns\_hostnames | Se a VPC tem ou não suporte para hostname DNS. |
| vpc\_enable\_dns\_support | Se a VPC tem ou não suporte a DNS. |
| vpc\_flow\_log\_destination\_type | O tipo de destino para o VPC Flow Logs. |
| vpc\_flow\_log\_id | O ID do recurso VPC Flow Logs. |
| vpc\_id | O id da VPC. |
| vpc\_main\_route\_table\_id | O id da main route table associada com a VPC. |
| vpc\_secondary\_cidr\_blocks | Lista de blocos CIDR secundários da VPC |
<!-- END_TF_DOCS -->