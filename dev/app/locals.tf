locals {
  region       = "us-east-2"
  region_alias = "use2"
  partition    = data.aws_partition.current.partition

  config    = yamldecode(file("../config.yaml"))
  workspace = local.config["workspaces"][var.env]

  domain_name    = "${var.env}.${local.sticker}.link" # trimsuffix(data.aws_route53_zone.this.name, ".")
  s3_domain_name = "s3.${local.region}.amazonaws.com"
  sticker        = "vmoura"

  vpc_name = yamldecode(file("../shared/config.yaml"))["workspaces"][var.env]["vpc"][0]["name"]
  vpc_cidr = yamldecode(file("../shared/config.yaml"))["workspaces"][var.env]["vpc"][0]["cidr_block"]
  azs      = slice(data.aws_availability_zones.available.names, 0, 3)

  ecr_url = ""

  default_tags = {
    Enviroment = var.env
    # Service      = "#{Service}#"
    Owner        = "Develonment Team"
    Description  = "Resource created by Terraform"
    CostType     = "CostType"
    Created_date = timestamp()
    Repo         = var.repository_name
    Builder      = "terraform"
  }
}