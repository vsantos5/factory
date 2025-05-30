module "ecs_cluster" {
  source  = "terraform-aws-modules/ecs/aws//modules/cluster"
  version = "5.12.0"

  for_each = { for ecss in local.workspace.ecs : ecss.cluster => ecss
  if ecss.cluster != "" && ecss.cluster != [] }

  cluster_name = "${each.value.cluster}-ecs-cluster-${local.sticker}-${var.env}-${local.region_alias}"

  # Capacity provider
  fargate_capacity_providers = {
    FARGATE = {
      default_capacity_provider_strategy = {
        weight = 3
      }
    }
    FARGATE_SPOT = {
      default_capacity_provider_strategy = {
        weight = 2
        base   = 1
      }
    }
  }

  tags = local.default_tags
}

module "ecs_service" {
  source  = "terraform-aws-modules/ecs/aws//modules/service"
  version = "5.12.0"

  for_each = local.workspace.ecs[0].service

  name                  = "${each.key}-ecs-svc-${local.sticker}-${var.env}-${local.region_alias}"
  cluster_arn           = module.ecs_cluster["main"].arn
  subnet_ids            = data.aws_subnets.private.ids
  create_security_group = false
  security_group_ids    = [module.sg["ecs"].security_group_id]

  cpu                      = try(each.value.cpu, 256)
  memory                   = try(each.value.memory, 512)
  desired_count            = try(each.value.desired_count, 1)
  enable_execute_command   = true
  autoscaling_max_capacity = try(each.value.autoscaling_max_capacity, 5)
  autoscaling_min_capacity = try(each.value.desired_count, 1)

  # Container definition(s)
  container_definitions = {

    "${each.key}" = {
      name        = "${each.key}-container-${local.sticker}-${var.env}-${local.region_alias}"
      cpu         = try(each.value.cpu, 256)
      memory      = try(each.value.memory, 512)
      essential   = true
      image       = local.ecr_url
      environment = try(each.value.environment, [])
      secrets     = try(each.value.secrets, [])
      mountPoints = try(each.value.mountPoints, [])

      readonly_root_filesystem = false

      port_mappings = [
        {
          containerPort = 443
          protocol      = "tcp"
        }
      ]

      enable_cloudwatch_logging = true
      log_configuration = {
        log_driver = "awslogs"
        options = {
          awslogs-group         = "/ecs/${each.key}-${var.env}-${local.region_alias}"
          awslogs-region        = local.region
          awslogs-stream-prefix = "${each.key}-${var.env}-${local.region_alias}"
        }
      }
    }
  }

  service_registries = {
    registry_arn = aws_service_discovery_service.this["${each.key}"].arn
  }

  load_balancer = {
    service = {
      target_group_arn = aws_lb_target_group.private["${each.key}"].arn
      container_name   = "${each.key}-container-${local.sticker}-${var.env}-${local.region_alias}"
      container_port   = 443
    }
  }

  depends_on = [module.ecs_cluster]

  tags = local.default_tags
}

resource "aws_service_discovery_private_dns_namespace" "this" {
  name        = "${var.env}.${local.sticker}.cloud"
  description = "CloudMap namespace for ${var.env}.${local.sticker}.cloud"
  vpc         = data.aws_vpc.vpc.id
  tags        = local.default_tags
}

resource "aws_service_discovery_service" "this" {
  for_each = local.workspace.ecs[0].service
  #for_each = local.workspace.ecs[0].service != [] ? local.workspace.ecs[0].service : {}

  name = "api.${each.key}"

  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.this.id

    dns_records {
      ttl  = 15
      type = "A"
    }

    routing_policy = "MULTIVALUE"
  }

  health_check_custom_config {
    failure_threshold = 1
  }

  depends_on = [aws_service_discovery_private_dns_namespace.this]

  tags = local.default_tags
}