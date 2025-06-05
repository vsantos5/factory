module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "9.14.0"

  for_each = { for albs in local.workspace.alb : albs.name => albs
  if albs.name != "" && albs.name != [] }

  name    = "${each.value.name}-alb-${local.sticker}-${var.env}-${local.region_alias}"
  vpc_id  = data.aws_vpc.vpc.id
  subnets = data.aws_subnets.public.ids

  enable_deletion_protection = false
  associate_web_acl                           = try(each.value.associate_web_acl, false)
  default_port                                = 443
  default_protocol                            = "HTTPS"
  internal                                    = try(each.value.internal, true)
  enable_http2                                = true
  enable_tls_version_and_cipher_suite_headers = true
  enable_waf_fail_open                        = false
  create_security_group                       = false

  security_groups = [module.sg["alb-${each.value.name}"].security_group_id]

  depends_on = [module.sg]

  tags = local.default_tags
}

resource "aws_lb_listener" "this" {
  for_each = { for albs in local.workspace.alb : albs.name => albs
  if albs.name != "" && albs.name != [] }

  load_balancer_arn = module.alb[each.value.name].arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-Res-2021-06"
  certificate_arn   = data.aws_acm_certificate.alb.arn

  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "404 - Not Found"
      status_code  = "404"
    }
  }

  tags = local.default_tags
}

resource "aws_lb_target_group" "private" {
  for_each = local.workspace.alb[0].service

  name        = "${each.key}-tg-alb-${var.env}-${local.region_alias}"
  port        = 443
  protocol    = "HTTPS"
  target_type = "ip"
  vpc_id      = data.aws_vpc.vpc.id

  health_check {
    interval            = try(each.value.health_check_interval, 300)
    path                = try(each.value.health_check_path, "/health")
    port                = try(each.value.health_check_port, 8080)
    protocol            = try(each.value.health_check_protocol, "HTTP")
    timeout             = try(each.value.health_check_timeout, 30)
    healthy_threshold   = try(each.value.healthy_threshold_count, 2)
    unhealthy_threshold = try(each.value.unhealthy_threshold_count, 2)
    matcher             = "200-499"
  }

  tags = local.default_tags
}

resource "aws_lb_target_group" "public" {
  for_each = local.workspace.alb[1].service

  name        = "${each.key}-tg-alb-${local.sticker}-${var.env}-${local.region_alias}"
  port        = 443
  protocol    = "HTTPS"
  target_type = "ip"
  vpc_id      = data.aws_vpc.vpc.id

  health_check {
    interval            = try(each.value.health_check_interval, 300)
    path                = try(each.value.health_check_path, "/health")
    port                = try(each.value.health_check_port, 8080)
    protocol            = try(each.value.health_check_protocol, "HTTP")
    timeout             = try(each.value.health_check_timeout, 30)
    healthy_threshold   = try(each.value.healthy_threshold_count, 2)
    unhealthy_threshold = try(each.value.unhealthy_threshold_count, 2)
    matcher             = "200-499"
  }

  tags = local.default_tags
}

resource "aws_lb_listener_rule" "private" {
  for_each = local.workspace.alb[0].service

  action {
    order            = each.value.priority
    target_group_arn = aws_lb_target_group.private["${each.key}"].arn
    type             = "forward"
  }

  condition {
    path_pattern {
      values = ["/${each.key}*"]
    }
  }
  condition {
    host_header {
      values = ["api.${local.domain_name}"]
    }
  }
  listener_arn = aws_lb_listener.this["private"].arn
  priority     = each.value.priority

  tags = local.default_tags
}

resource "aws_lb_listener_rule" "public" {
  for_each = local.workspace.alb[1].service

  action {
    order            = each.value.priority
    target_group_arn = aws_lb_target_group.public["${each.key}"].arn
    type             = "forward"
  }

  condition {
    path_pattern {
      values = ["/${each.key}*"]
    }
  }
  listener_arn = aws_lb_listener.this["public"].arn
  priority     = each.value.priority

  tags = local.default_tags
}