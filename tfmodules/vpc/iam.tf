data "aws_iam_policy_document" "default_endpoint_policy" {
  count = var.vpc_interface_endpoints != {} || var.create_vpc_gateway_endpoints ? 1 : 0
  statement {
    effect    = "Allow"
    actions   = ["*"]
    resources = ["*"]

    principals {
      type        = "*"
      identifiers = ["*"]
    }
  }
}
