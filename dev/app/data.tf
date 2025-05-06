data "aws_canonical_user_id" "current" {}

data "aws_cloudfront_log_delivery_canonical_user_id" "cloudfront" {}

data "aws_availability_zones" "available" {}

data "aws_caller_identity" "current" {}

data "aws_partition" "current" {}

data "aws_cloudfront_cache_policy" "cachingoptimized" {
  name = "Managed-CachingOptimized"
}

data "aws_availability_zones" "public" {
  # Exclude local zones
  filter {
    name   = "opt-in-status"
    values = ["opt-in-not-required"]
  }
}

data "aws_acm_certificate" "certs" {
  for_each = { for buckets in local.workspace.cloudfront : buckets.bkt_name => buckets
  if buckets.bkt_name != "" && buckets.bkt_name != [] }
  domain   = "${each.value.bkt_name}.${local.domain_name}"
  statuses = ["ISSUED"]
  provider = aws.use1
}

data "aws_acm_certificate" "alb" {
  domain   = "api.${var.env}.${local.sticker}.com"
  statuses = ["ISSUED"]
}
/*
data "aws_route53_zone" "this" {
  zone_id = "Z054134010OGTY3T94LDO"
  #vpc_id = "vpc-01a9485c5c8a18893"
}
*/
data "aws_vpc" "vpc" {
  tags = {
    Name = "vpc-${local.sticker}-${var.env}"
  }
}

data "aws_subnets" "all" {
  filter {
    name   = "tag:Name"
    values = ["subnet-${local.sticker}-${var.env}-*"]
  }
}

data "aws_subnets" "public" {
  filter {
    name   = "tag:Name"
    values = ["subnet-${local.sticker}-${var.env}-public-*"]
  }
}

data "aws_subnets" "private" {
  filter {
    name   = "tag:Name"
    values = ["subnet-${local.sticker}-${var.env}-private-*"]
  }
}

data "aws_security_group" "alb-private" {
  filter {
    name   = "tag:Name"
    values = ["alb-private-sg-${local.sticker}-*"]
  }
}

data "aws_security_group" "alb-public" {
  filter {
    name   = "tag:Name"
    values = ["alb-public-sg-${local.sticker}-*"]
  }
}
/*
data "terraform_remote_state" "shared" {
  backend = "s3"
  config = {
    key            = "app/terraform.tfstate"
    bucket         = "terraform-${local.sticker}-${var.env}-${local.region_alias}"
    dynamodb_table = "${local.sticker}-terraform-${var.env}-shared"
    region         = local.region
    #profile        = "workload-${var.environment}"
  }
}


#######################################################
data "aws_iam_policy_document" "bucket_read_policy" {
  for_each = { for buckets in local.workspace.frontend : buckets.bkt_name => buckets }
  statement {
    principals {
      type        = "AWS"
      identifiers = ["*"] #aws_cloudfront_origin_access_identity.CloudFrontOAI.iam_arn]
    }

    actions = [
      "s3:GetObject",
    ]

    resources = [
      "arn:aws:s3:::${each.value.bkt_name}-${local.sticker}-${var.env}-${local.region_alias}/*"
      #"${module.s3_frontend["${each.value.bkt_name}"].s3_bucket_arn}/*"
      #"${aws_s3_bucket.merchant-panel-ui.arn}/*" ##################################
    ]
  }

  statement {
    principals {
      type        = "AWS"
      identifiers = ["*"] #aws_cloudfront_origin_access_identity.CloudFrontOAI.iam_arn]
    }

    actions = [
      "s3:ListBucket",
    ]

    resources = [
      "arn:aws:s3:::${each.value.bkt_name}-${local.sticker}-${var.env}-${local.region_alias}"
      #module.s3_frontend["${each.value.bkt_name}"].s3_bucket_arn
    ]
  }
}
*/