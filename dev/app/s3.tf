module "s3" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "4.6.0"

  for_each = { for buckets in local.workspace.s3 : buckets.bkt_name => buckets
  if buckets.bkt_name != "" && buckets.bkt_name != [] }

  bucket = "${each.value.bkt_name}-${local.sticker}-${var.env}-${local.region_alias}"
  acl    = "private"

  control_object_ownership = true
  object_ownership         = "ObjectWriter"

  versioning = {
    status     = try(each.value.versioning, true) #Flag to inform if versioning is to be enabled(true=default).
    mfa_delete = false
  }

  server_side_encryption_configuration = {
    rule = {
      apply_server_side_encryption_by_default = {
        kms_master_key_id = try(each.value.kms_key_arn, "")         #KMS key ARN used to encrypt the bucket. This information just need to be used when the sse_algorithm for aws:kms. By default, the aws/s3 key will be used.
        sse_algorithm     = try(each.value.sse_algorithm, "AES256") #Algoritym used to encrypt the objects into bucket. Allowed values: AES256 or aws:kms
      }
    }
  }

  cors_rule = try(each.value.cors_rule, [])

  lifecycle_rule = [
    {
      id      = "${each.value.bkt_name}_lifecycle_rule"
      enabled = true
      transition = [
        {
          days          = try(each.value.transition_standard_ia, 30) #Time in days to move the objects to S3 Standard IA class.
          storage_class = "STANDARD_IA"
        },
        {
          days          = try(each.value.transition_glacier, 90) #Time in days to move the objects to S3 Glacier class.
          storage_class = "GLACIER"
        }
      ]
      expiration = {
        days                         = try(each.value.expiration, null) #Time in days to expire the objects on S3. To disable it use null value.
        expired_object_delete_marker = false
      }

      noncurrent_version_expiration = {
        newer_noncurrent_versions = 5
        days                      = try(each.value.non_current_expiration, 30) #Time in days to expire old versions of objects.
      }
    }
  ]

  tags = local.default_tags

}