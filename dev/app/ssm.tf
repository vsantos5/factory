module "ssm-parameter" {
  source  = "terraform-aws-modules/ssm-parameter/aws"
  version = "1.1.2"

  for_each = { for ssms in local.workspace.ssm : ssms.name => ssms
  if ssms.name != "" && ssms.name != [] }

  name            = each.value.name
  value           = try(each.value.value, null)
  values          = try(each.value.values, [])
  type            = try(each.value.type, null)
  secure_type     = try(each.value.secure_type, null)
  description     = try(each.value.description, null)
  tier            = try(each.value.tier, null)
  key_id          = try(each.value.key_id, null)
  allowed_pattern = try(each.value.allowed_pattern, null)
  data_type       = try(each.value.data_type, null)

  tags = local.default_tags
}