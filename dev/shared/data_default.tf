/*
data "aws_subnet_ids" "subnet_ids" {
  vpc_id = data.aws_vpcs.vpc.ids[0]
}

data "aws_subnet" "subnet_id" {
  for_each = data.aws_subnet_ids.subnet_ids.ids
  id       = each.value
}

data "aws_subnet" "private_subnet_za" {
  filter {
    name   = "tag:Name"
    values = ["private*1a"]
  }
}

data "aws_subnet" "private_subnet_zb" {
  filter {
    name   = "tag:Name"
    values = ["private*1b"]
  }
}

data "aws_subnet" "private_subnet_zc" {
  filter {
    name   = "tag:Name"
    values = ["private*1c"]
  }
}

data "aws_subnet" "public_subnet_za" {
  filter {
    name   = "tag:Name"
    values = ["public*1a"]
  }
}

data "aws_subnet" "public_subnet_zb" {
  filter {
    name   = "tag:Name"
    values = ["public*1b"]
  }
}

data "aws_subnet" "public_subnet_zc" {
  filter {
    name   = "tag:Name"
    values = ["public*1c"]
  }
}

data "aws_subnet" "database_subnet_za" {
  filter {
    name   = "tag:Name"
    values = ["database*1a"]
  }
}

data "aws_subnet" "database_subnet_zb" {
  filter {
    name   = "tag:Name"
    values = ["database*1b"]
  }
}

data "aws_subnet" "database_subnet_zc" {
  filter {
    name   = "tag:Name"
    values = ["database*1c"]
  }
}

output "subnet_cidr_blocks" {
  value = [for subnet in data.aws_subnet.subnet_id : subnet.cidr_block]
}

output "subnet_arn" {
  value = [for subnet in data.aws_subnet.subnet_id : subnet.arn]
}

locals {
  private_subnet_ids = [
    "${data.aws_subnet.private_subnet_za.id}",
    "${data.aws_subnet.private_subnet_zb.id}",
    "${data.aws_subnet.private_subnet_zc.id}"
  ]

  public_subnet_ids = [
    "${data.aws_subnet.public_subnet_za.id}",
    "${data.aws_subnet.public_subnet_zb.id}",
    "${data.aws_subnet.public_subnet_zc.id}"
  ]

  endpoint_subnet_ids = [
    "${data.aws_subnet.database_subnet_za.id}",
    "${data.aws_subnet.database_subnet_zb.id}",
    "${data.aws_subnet.database_subnet_zc.id}"
  ]

  private_subnet_range  = "${cidrhost(cidrsubnet(data.aws_subnet.private_subnet_za.cidr_block, -3, 0), 0)}/22"
  public_subnet_range   = "${cidrhost(cidrsubnet(data.aws_subnet.public_subnet_za.cidr_block, -3, 0), 0)}/24"
  database_subnet_range = "${cidrhost(cidrsubnet(data.aws_subnet.database_subnet_za.cidr_block, -3, 0), 0)}/24"
}
*/