# module "eks-blueprints-addons" {
#   source  = "aws-ia/eks-blueprints-addons/aws"
#   version = "~> 1.21.0"

#   for_each = { for ekss in local.workspace.eks : ekss.cluster => ekss
#   if ekss.cluster != "" && ekss.cluster != [] }

#   cluster_name      = "${each.value.cluster}-eks-cluster-${var.env}-${local.region_alias}"
#   cluster_endpoint  = module.eks["${each.value.cluster}"].cluster_endpoint
#   cluster_version   = each.value.cluster_version
#   oidc_provider_arn = module.eks["${each.value.cluster}"].oidc_provider_arn

#   eks_addons = {
#     aws-ebs-csi-driver = {
#       most_recent = true
#     }
#     coredns = {
#       most_recent = true
#     }
#     vpc-cni = {
#       before_compute = true
#       most_recent    = true
#     }
#     kube-proxy = {
#       most_recent = true
#     }
#   }

#   # https://github.com/aws-ia/terraform-aws-eks-blueprints-addons/blob/main/docs/addons/aws-load-balancer-controller.md
#   # kubectl get deployment aws-load-balancer-controller -n kube-system -o yaml | less
#   enable_aws_load_balancer_controller = true

#   # https://github.com/aws-ia/terraform-aws-eks-blueprints-addons/blob/main/docs/addons/aws-node-termination-handler.md
#   #enable_aws_node_termination_handler = try(each.value.enable_node_termination_handler, true)
#   enable_argocd = try(each.value.enable_argocd, true)
#   # After enabling argocd, run the following command to change itś Service Type to LoadBalancer
#   # kubectl -n argocd patch svc argo-cd-argocd-server -p '{"spec": {"type": "LoadBalancer"}}'
#   # Get the argocd andpoint
#   # kubectl -n argocd get service argo-cd-argocd-server -o jsonpath="{.status.loadBalancer.ingress[*].hostname}{'\n'}"
#   # Get the Admin password
#   # echo "$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)"

#   enable_metrics_server        = try(each.value.enable_metrics_server, true) # kubectl top node
#   enable_kube_prometheus_stack = try(each.value.enable_kube_prometheus_stack, true)
#   # get secret kube-prometheus-stack-grafana -n kube-prometheus-stack -o jsonpath="{.data.admin-user}" | base64 -d
#   # kubectl get secret kube-prometheus-stack-grafana -n kube-prometheus-stack -o jsonpath="{.data.admin-password}" | base64 -d
#   # kubectl -n kube-prometheus-stack port-forward svc/kube-prometheus-stack-grafana 50080:80
#   # open this browser: http://localhost:50080/

#   # https://github.com/aws-ia/terraform-aws-eks-blueprints-addons/blob/main/docs/addons/external-dns.md
#   enable_external_dns = try(each.value.enable_external_dns, true)

#   # https://github.com/aws-ia/terraform-aws-eks-blueprints-addons/blob/main/docs/addons/cert-manager.md
#   enable_cert_manager = try(each.value.enable_cert_manager, true)
#   #cert_manager_route53_hosted_zone_arns  = data.aws_route53_zone.this.arn #["arn:aws:route53:::hostedzone/XXXXXXXXXXXXX"]

#   # https://github.com/aws-ia/terraform-aws-eks-blueprints-addons/blob/main/docs/addons/cluster-proportional-autoscaler.md
#   # enable_cluster_proportional_autoscaler = try(each.value.enable_cluster_autoscaler, true)
#   # cluster_proportional_autoscaler = {
#   #   values = [
#   #     <<-EOT
#   #       nameOverride: kube-dns-autoscaler

#   #       # Formula for controlling the replicas. Adjust according to your needs
#   #       # replicas = max( ceil( cores * 1/coresPerReplica ) , ceil( nodes * 1/nodesPerReplica ) )
#   #       config:
#   #         linear:
#   #           coresPerReplica: 256
#   #           nodesPerReplica: 16
#   #           min: 1
#   #           max: 100
#   #           preventSinglePointFailure: true
#   #           includeUnschedulableNodes: true

#   #       # Target to scale. In format: deployment/*, replicationcontroller/* or replicaset/* (not case sensitive).
#   #       options:
#   #         target: deployment/* # Notice the target as `deployment/coredns`

#   #       serviceAccount:
#   #         create: true
#   #         name: kube-dns-autoscaler

#   #       podSecurityContext:
#   #         seccompProfile:
#   #           type: RuntimeDefault
#   #           supplementalGroups: [65534]
#   #           fsGroup: 65534

#   #       resources:
#   #         limits:
#   #           cpu: 100m
#   #           memory: 128Mi
#   #         requests:
#   #           cpu: 100m
#   #           memory: 128Mi

#   #       tolerations:
#   #         - key: "CriticalAddonsOnly"
#   #           operator: "Exists"
#   #           description: "Cluster Proportional Autoscaler for CoreDNS Service"
#   #     EOT
#   #   ]
#   # }

#   depends_on = [module.eks]

#   tags = local.default_tags
# }

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "20.36.0"

  for_each = { for ekss in local.workspace.eks : ekss.cluster => ekss
  if ekss.cluster != "" && ekss.cluster != [] }

  cluster_name    = "${each.value.cluster}-eks-cluster-${var.env}-${local.region_alias}"
  cluster_version = each.value.cluster_version

  vpc_id                   = data.aws_vpc.vpc.id
  subnet_ids               = data.aws_subnets.private.ids
  control_plane_subnet_ids = data.aws_subnets.private.ids

  enable_cluster_creator_admin_permissions = true
  cluster_endpoint_public_access           = true

  cluster_addons = {
    coredns                = {}
    eks-pod-identity-agent = {}
    kube-proxy             = {}
    vpc-cni                = {}
  }

  eks_managed_node_groups = {
    karpenter = {
      ami_type       = "BOTTLEROCKET_x86_64"
      instance_types = try(each.value.instance_types, ["m5.xlarge"])
      capacity_type  = try(each.value.capacity_type, "SPOT")
      subnet_ids     = data.aws_subnets.private.ids

      min_size     = try(each.value.min_cluster_size, 1)
      max_size     = try(each.value.max_cluster_size, 2)
      desired_size = try(each.value.desired_cluster_size, 1)

      labels = {
        # Used to ensure Karpenter runs on nodes that it does not manage
        "karpenter.sh/controller" = "true"
      }
    }
  }

  cluster_security_group_tags = {
    "karpenter.sh/discovery" = "${each.value.cluster}-eks-cluster-${var.env}-${local.region_alias}"
  }

  node_security_group_tags = {
    "karpenter.sh/discovery" = "${each.value.cluster}-eks-cluster-${var.env}-${local.region_alias}"
  }

  tags = local.default_tags
}

################################################################################
# Karpenter
################################################################################
module "eks_karpenter" {
  source  = "terraform-aws-modules/eks/aws//modules/karpenter"
  version = "20.36.0"

  for_each = { for ekss in local.workspace.eks : ekss.cluster => ekss
  if ekss.cluster != "" && ekss.cluster != [] }

  cluster_name          = "${each.value.cluster}-eks-cluster-${var.env}-${local.region_alias}"
  enable_v1_permissions = true

  # Name needs to match role name passed to the EC2NodeClass
  node_iam_role_use_name_prefix   = false
  node_iam_role_name              = "${each.value.cluster}-eks-cluster-${var.env}-${local.region_alias}"
  create_pod_identity_association = true

  # Used to attach additional IAM policies to the Karpenter node IAM role
  node_iam_role_additional_policies = {
    AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  }

  tags = local.default_tags
}

resource "helm_release" "karpenter" {
  for_each = { for ekss in local.workspace.eks : ekss.cluster => ekss
  if ekss.cluster != "" && ekss.cluster != [] }

  namespace           = "kube-system"
  name                = "karpenter"
  repository          = "oci://public.ecr.aws/karpenter"
  chart               = "karpenter"
  version             = "1.1.1" #1.2.3
  wait                = false

  values = [
    <<-EOT
    nodeSelector:
      karpenter.sh/controller: 'true'
    dnsPolicy: Default
    settings:
      clusterName: "${each.value.cluster}-eks-cluster-${var.env}-${local.region_alias}"
      clusterEndpoint: "${module.eks[each.value.cluster].cluster_endpoint}"
      interruptionQueue: "Karpenter-${each.value.cluster}-eks-cluster-${var.env}-${local.region_alias}"
    webhook:
      enabled: false
    EOT
  ]
}

#Add Tags for the new cluster in the VPC Subnets
resource "aws_ec2_tag" "private_subnets" {
  for_each    = toset(data.aws_subnets.private.ids)
  resource_id = each.value
  key         = "karpenter.sh/discovery"
  value       = "main-eks-cluster-${var.env}-${local.region_alias}"
}

resource "aws_ec2_tag" "public_subnets" {
  for_each    = toset(data.aws_subnets.public.ids)
  resource_id = each.value
  key         = "karpenter.sh/discovery"
  value       = "main-eks-cluster-${var.env}-${local.region_alias}"
}