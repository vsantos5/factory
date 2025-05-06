module "s3" {
  for_each = { for buckets in local.workspace.s3 : buckets.bkt_name => buckets }
  source = "terraform-aws-modules/s3-bucket/aws"
  version = "4.6.0"

  bucket = "${each.value.bkt_name}-${local.sticker}-${var.env}-${local.region_alias}"
  acl    = "private"

  control_object_ownership = true
  object_ownership         = "ObjectWriter"

  versioning = {
    status     = try(each.value.versioning, true) #Flag para informar se o versionamento deve ser habilitado(true=default) para o bucket do Flow Logs criado pelo modulo.
    mfa_delete = false
  }

  server_side_encryption_configuration = {
    rule = {
      apply_server_side_encryption_by_default = {
        kms_master_key_id = try(each.value.kms_key_arn, "") #ARN da Chave KMS utilizada para cirptografar o bucket do Flow Logs criado pelo modulo. Essa informacao so precisa ser utilizada quando o sse_algorithm for aws:kms. Por padrao, a chave utilizada sera aws/s3.
        sse_algorithm     = try(each.value.sse_algorithm, "AES256") #Algoritimo utilizado para criptografar os dados do bucket do Flow Logs criado pelo modulo. Valores validos: AES256 ou aws:kms
      }
    }
  }

  lifecycle_rule = [
    {
      id      = "${each.value.bkt_name}_lifecycle_rule"
      enabled = true
      transition = [
        {
          days          = try(each.value.transition_standard_ia, 30) #Periodo em dias para mover os objetos para a classe S3 Standard IA, no bucket do Flow Logs criado pelo modulo.
          storage_class = "STANDARD_IA"
          },
          {
          days          = try(each.value.transition_glacier, 90) #Periodo em dias para mover os objetos para a classe S3 Glacier, no bucket do Flow Logs criado pelo modulo.
          storage_class = "GLACIER"
        }
      ]
      expiration = {
        days                         = try(each.value.expiration, null) #Periodo em dias para expirar os logs no bucket do Flow Logs criado pelo modulo. Para desabilitar utilize o valor null.
        expired_object_delete_marker = false
      }

      noncurrent_version_expiration = {
        newer_noncurrent_versions = 5
        days                      = try(each.value.non_current_expiration, 30) #Periodo em dias para expirar as versões antigas dos logs, no bucket do Flow Logs criado pelo modulo.
      }
    }
  ]

  tags = local.default_tags

}