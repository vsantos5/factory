module "cloudfront" {
  for_each = { for buckets in local.workspace.cloudfront : buckets.bkt_name => buckets
  if buckets.bkt_name != "" && buckets.bkt_name != [] }
  source  = "terraform-aws-modules/cloudfront/aws"
  version = "4.1.0"

  aliases = ["${each.value.bkt_name}.${local.domain_name}"]

  comment             = "CloudFront distribution for ${each.value.bkt_name}.${local.domain_name}"
  http_version        = "http2and3"
  price_class         = "PriceClass_All"
  wait_for_deployment = false

  default_root_object          = "index.html"
  create_origin_access_control = true
  origin_access_control = {
    s3_oac = {
      description      = "CloudFront access to S3"
      origin_type      = "s3"
      signing_behavior = "always"
      signing_protocol = "sigv4"

      origin_shield = {
        enabled              = true
        origin_shield_region = local.region
      }
    }
  }

  logging_config = {
    bucket = module.s3["logs"].s3_bucket_bucket_domain_name
    prefix = "${each.value.bkt_name}-${local.sticker}-cloudfront-logs"
  }

  origin = {
    "${each.value.bkt_name}" = {
      domain_name = "${each.value.bkt_name}-${local.sticker}-${var.env}-${local.region_alias}.${local.s3_domain_name}"

      origin_access_control = "s3_oac" # key in `origin_access_control`

      origin_shield = {
        enabled              = true
        origin_shield_region = local.region
      }
    }
  }

  default_cache_behavior = {
    target_origin_id       = "${each.value.bkt_name}"
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]

    use_forwarded_values = false
    cache_policy_id      = data.aws_cloudfront_cache_policy.cachingoptimized.id
  }

  viewer_certificate = {
    acm_certificate_arn      = data.aws_acm_certificate.certs["${each.value.bkt_name}"].arn
    minimum_protocol_version = "TLSv1.2_2021"
    ssl_support_method       = "sni-only"
  }

  custom_error_response = [{
    error_code         = 404
    response_code      = 404
    response_page_path = "/index.html"
    }, {
    error_code         = 403
    response_code      = 403
    response_page_path = "/index.html"
  }]

  geo_restriction = {
    restriction_type = "none"
  }

  depends_on = [module.s3_frontend]

  tags = local.default_tags
}
/*
module "acm" {
  source  = "terraform-aws-modules/acm/aws"
  version = "5.1.1"

  domain_name               = local.domain_name
  zone_id                   = data.aws_route53_zone.this.id
  subject_alternative_names = ["${local.subdomain}.${local.domain_name}"]
}
*/
module "s3_frontend" {
  for_each = { for buckets in local.workspace.cloudfront : buckets.bkt_name => buckets
  if buckets.bkt_name != "" && buckets.bkt_name != [] }
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "4.6.0"

  bucket = "${each.value.bkt_name}-${local.sticker}-${var.env}-${local.region_alias}"
  acl    = "private"

  control_object_ownership = true
  object_ownership         = "ObjectWriter"

  versioning = {
    status     = true
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

  tags = local.default_tags

}