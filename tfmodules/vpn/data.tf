data "aws_vpc" "network" {
  tags = {
    Name = var.vpc_name
  }
}

data "aws_ec2_transit_gateway" "network" {
  filter {
    name   = "tag:Name"
    values = [var.tgw_name]
  }
}

data "aws_customer_gateway" "network" {
  filter {
    name   = "tag:Name"
    values = [var.cgw_name]
  }
}