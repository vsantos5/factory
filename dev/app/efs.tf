module "efs" {
  source  = "terraform-aws-modules/efs/aws"
  version = "1.8.0"

  for_each = { for efss in local.workspace.efs : efss.name => efss
  if efss.name != "" && efss.name != [] }

  # File system
  name      = "${each.value.name}-efs-bazk-${var.env}-${local.region_alias}"
  encrypted = true

  lifecycle_policy = {
    transition_to_ia                    = "AFTER_30_DAYS"
    transition_to_primary_storage_class = "AFTER_1_ACCESS"
  }

  # File system policy
  attach_policy                             = true
  deny_nonsecure_transport_via_mount_target = false
  bypass_policy_lockout_safety_check        = false
  policy_statements = [
    {
      sid     = "efs"
      actions = ["elasticfilesystem:ClientMount"]
      principals = [
        {
          type        = "AWS"
          identifiers = [data.aws_caller_identity.current.arn]
        }
      ]
    }
  ]

  # Mount targets / security group
  mount_targets = {
    for az, subnet in zipmap(local.azs, slice(data.aws_subnets.private.ids, 0, length(local.azs))) :
    az => { subnet_id = subnet }
  }
  security_group_description = "EFS security group"
  security_group_vpc_id      = data.aws_vpc.vpc.id
  security_group_rules = {
    vpc = {
      # relying on the defaults provided for EFS/NFS (2049/TCP + ingress)
      description = "NFS ingress from VPC private subnets"
      cidr_blocks = [data.aws_vpc.vpc.cidr_block]
    }
  }

  access_points = {
    "${each.value.name}" = {
      root_directory = {
        path = "/${each.value.name}"
        creation_info = {
          owner_gid   = 1001
          owner_uid   = 1001
          permissions = "755"
        }
      }
    }
  }

  enable_backup_policy = try(each.value.enable_backup, false)

  # Replication configuration
  create_replication_configuration = try(each.value.enable_replication, false)
  replication_configuration_destination = {
    region = "sa-east-1"
  }

  tags = local.default_tags
}