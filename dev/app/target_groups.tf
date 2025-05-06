/*
locals {
  priv_listeners = {
    priv_listeners = { for rules in local.workspace.alb["private"].rule : rules.rule => rules }
    https = {
      port            = 443
      protocol        = "HTTPS"
      ssl_policy      = "ELBSecurityPolicy-TLS13-1-2-Res-2021-06"
      certificate_arn = data.aws_acm_certificate.alb.arn

      fixed_response = {
        content_type = "text/plain"
        status_code  = 404
        message_body = "Page not found!"
      }

      rules = {
        "${each.value.name}" = {
          priority = 1
          actions = [{
            type = "weighted-forward"
            target_groups = [
              {
                target_group_key = "${each.value.name}"
                weight           = 1
              }
            ]
            stickiness = {
              enabled  = false
              duration = 3600
            }
          }]

          conditions = [{
            host_header = {
              values = ["api.${var.env}.bazk.com"]
            },
            path_pattern = {
              values = [for rule in local.workspace.alb[0].rule : "/${rule.health_check_path}*"]
            }
          }]
        }
      }
    }
  }
}
*/