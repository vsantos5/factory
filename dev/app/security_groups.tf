locals {
  security_groups = {
    # External ALB Security Group Rules
    alb-public = {
      description         = "Security group for public ALB"
      ingress_cidr_blocks = ["0.0.0.0/0"]
      ingress_rules       = ["https-443-tcp", "http-80-tcp"]
    }

    # Internal ALB Security Group Rules
    alb-private = {
      description = "Security group for private ALB"
      ingress_cidr_blocks = [
        data.aws_vpc.vpc.cidr_block, #VPC
        "100.96.0.0/11",             #VPN
        "201.22.213.218/32",         #VIVO
        "170.233.229.105/32"         #Blue3
      ]
      ingress_rules = ["https-443-tcp", "http-80-tcp"]
    }

    # ECS Security Group Rules
    ecs = {
      description = "Security group for ECS"
      ingress_with_source_security_group_id = [
        {
          rule                     = "https-443-tcp"
          description              = "Public ALB SG"
          source_security_group_id = data.aws_security_group.alb-public.id
        }
      ]
    }
  }
}

module "sg" {
  for_each = local.security_groups
  source   = "terraform-aws-modules/security-group/aws"
  version  = "5.3.0"

  name        = "${each.key}-sg-bazk-${var.env}-${local.region_alias}"
  description = each.value.description
  vpc_id      = data.aws_vpc.vpc.id

  ingress_cidr_blocks                   = try(each.value.ingress_cidr_blocks, [])
  ingress_rules                         = try(each.value.ingress_rules, [])
  ingress_with_source_security_group_id = try(each.value.ingress_with_source_security_group_id, [])

  egress_cidr_blocks = ["0.0.0.0/0"]
  egress_rules       = ["all-all"]

  tags = local.default_tags
}