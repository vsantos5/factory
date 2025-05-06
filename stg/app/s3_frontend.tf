module "s3_bucket" {
  for_each = { for buckets in local.workspace.s3_frontend : buckets.bkt_name => buckets }
  source = "terraform-aws-modules/s3-bucket/aws"
  version = "4.6.0"

  bucket = "${each.value.bkt_name}-${local.sticker}-${var.env}-${local.region_alias}"
  acl    = "private"

  control_object_ownership = true
  object_ownership         = "ObjectWriter"

  versioning = {
    status     = true #Flag para informar se o versionamento deve ser habilitado(true=default) para o bucket do Flow Logs criado pelo modulo.
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

  website = {

    index_document = "index.html"
    error_document = "error.html"
  }

  tags = local.default_tags

}