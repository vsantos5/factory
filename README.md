# AWS Infrastructure Provisioning with config.yaml

This repository provisions AWS infrastructure using Terraform, driven by a YAML configuration file. All environments and resources are defined in `config.yaml`, making it easy to manage and replicate infrastructure across different environments.

Some custom information also needs to be parameterized in `locals.tf`. Remember that Security Group rules should be customized in the `security_groups.tf` file according to the needs of each scenario.

---

## Table of Contents

- [Overview](#overview)
- [Folder Structure](#folder-structure)
- [How config.yaml Works](#how-configyaml-works)
- [Supported Resources](#supported-resources)
- [Usage Instructions](#usage-instructions)
- [Example: Adding a New Service](#example-adding-a-new-service)
- [Tips & Troubleshooting](#tips--troubleshooting)

---

## Overview

- All AWS resources (VPC, ALB, ECS, EFS, EKS, CloudFront, etc.) are defined in a single YAML file that serves as a parameter for resource creation.
- Terraform reads this file and uses the information to create resources dynamically.
- The approach supports multiple environments (dev, prod, etc.), or environments can also be created separately.

---

## Folder Structure

```
<workload>/
  <environment>/
    app/
      *.tf                # Terraform modules and resources
    config.yaml           # Main environment configuration
    shared/
      config.yaml         # VPC configurations
```

---

## How config.yaml Works

- The file is structured by workspaces (e.g., `dev`, `qa`, `prod`).
- Each section (e.g., `alb`, `ecs`, `efs`, `eks`, `cloudfront`) lists resources and their parameters.
- Only required parameters are necessary for resource creation. Optional parameters can be provided for customization; if omitted, default values from the modules will be used.

**Example:**
```yaml
workspaces:
  dev:
    alb:
      - name: private
        internal: true
        service:
          core:
            priority: 1
            health_check_path: /core/actuator/health
            health_check_interval: 300
            health_check_timeout: 120
            healthy_threshold_count: 3
            unhealthy_threshold_count: 3
          backoffice:
            priority: 2
      - name: public
        internal: false
        service:
          gateway:
            priority: 1
            health_check_path: /gateway/health
    ecs:
      - cluster: main
        service:
          core:
            cpu: 256
            memory: 512
            desired_count: 1
    eks:
      - cluster: []
```

---

## Supported Resources

- **VPC**: Defined in `shared/config.yaml`
- **ALB**: Application Load Balancers (private/public)
- **CloudFront**: Distributions using S3 buckets
- **ECS**: ECS clusters and services
- **EFS**: Elastic File Systems
- **EKS**: Kubernetes clusters
- **S3**: Private S3 buckets
- **SSM**: Parameter storage

---

## Usage Instructions

1. **Edit `config.yaml`**  
   Update or add resources in the appropriate workspace (e.g., `dev`).
   Provide parameter values for resource creation.
   If you don't need a resource to be created, just set the key parameter as an empty list `[]`.
   Once the resources have been initially deployed, you need to uncomment the `data "aws_security_group" "alb-private"` and `data "aws_security_group" "alb-public"` data sources in `dev/app/data.tf`.
   You must also uncomment the `source_security_group_id` value within the ECS Security Group definition in `dev/app/security_groups.tf`.

2. **Initialize Terraform**  
   ```bash
   terraform init
   ```

3. **Plan the Deployment**  
   ```bash
   terraform plan
   ```

4. **Apply the Deployment**  
   ```bash
   terraform apply
   ```

5. **Destroy Resources (if needed)**  
   ```bash
   terraform destroy
   ```

---

## Example: Adding New Services

1. In `dev/config.yaml`:
   ```yaml
   workspaces:
    dev:
      alb:
        # ECS/EKS uses the private ALB to route traffic to the services.
        # IF deleted the ECS will not work.
        # Don't change the private ALB name, it is used in other modules.
        - name: private # REQUIRED FIELD
          internal: true
          service:
            core:
              priority: 1
              health_check_path: /core/actuator/health
              health_check_interval: 300
              health_check_timeout: 120
              healthy_threshold_count: 3
              unhealthy_threshold_count: 3
            backoffice:
              priority: 2
        # ECS/EKS uses the public ALB to route traffic to the services.
        # IF deleted the ECS will not work.
        # Don't change the public ALB name, it is used in other modules.
        - name: public # REQUIRED FIELD
          internal: false
          service:
            gateway:
              priority: 1
              health_check_path: /gateway/actuator/health
              health_check_interval: 300
              health_check_timeout: 120
              healthy_threshold_count: 3
              unhealthy_threshold_count: 3
      
      cloudfront:
        - bkt_name: frontend # REQUIRED FIELD

      ecs:
        - cluster: main # REQUIRED FIELD
          service:
            core:
              cpu: 256
              memory: 512
              desired_count: 1
              autoscaling_max_capacity: 2
              environment: 
                - name: AWS_REGION
                  value: sa-east-1
                - name: RABBIT_MQ_ENABLE_SSL
                  value: true
                - name: SPRING_PROFILES_ACTIVE
                  value: "dev"
              secrets:
                - name: AWS_ACCESS_KEY
                  valueFrom: service_aws_access_key_dev
                - name: AWS_SECRET_KEY
                  valueFrom: service_aws_secret_key_dev
              mountPoints:
                - sourceVolume: certificates
                  containerPath: /etc/certificates
            backoffice:

      efs:
        - name: certificates # REQUIRED FIELD
          enable_backup: false
          enable_replication: false

      # Improvements to fix
      # Before creating the EKS cluster, you need to uncomment the kubernetes/helm providers in `providers.tf`
      # This feature supports only one EKS cluster per workspace.
      # If you need to create more than one EKS cluster, you need to create a new workspace.
      eks:
        - cluster: main # REQUIRED FIELD
          cluster_version: 1.31 # REQUIRED FIELD
          instance_types: ["m6i.large", "m5.xlarge", "m5n.2xlarge"]
          capacity_type: SPOT # "SPOT" : "ON_DEMAND"
          min_cluster_size: 1
          max_cluster_size: 3
          desired_cluster_size: 1
          enable_karpenter: true
          enable_argocd: true
          enable_kube_prometheus_stack: true
          enable_metrics_server: true
          enable_external_dns: true
          enable_cert_manager: true
      
      s3:
        - bkt_name: logs # REQUIRED FIELD
          versioning: false
          cors_rule: [
            {
              allowed_methods: ["PUT", "GET"],
              allowed_origins: ["https://dev.logs.com"],
              allowed_headers: ["*"],
              expose_headers: []
            }
          ]

      ssm:
        - name: REGION # REQUIRED FIELD
          value: sa-east-1 # REQUIRED FIELD
          type: String # REQUIRED FIELD
          description: AWS Region used by the application
   ```
2. Run `terraform plan` and `terraform apply` as above.

---

## Tips & Troubleshooting

- **Empty Arrays**: Use `[]` for unused slots, but remove or fill them for actual provisioning.
- **YAML Syntax**: Ensure correct indentation and no trailing commas.
- **Multiple Environments**: Duplicate the `dev` block as `prod`, `staging`, etc.
- **Shared Resources**: Use `shared/config.yaml` for VPC and networking resources.
- **Resource Mapping**: The order of items in arrays (e.g., `alb[0]`, `alb[1]`) matters for mapping private/public resources in Terraform.

---

## References

- [Terraform AWS Modules](https://github.com/terraform-aws-modules)
- [YAML Syntax Guide](https://yaml.org/spec/1.2/spec.html)

---

**For questions, open an issue or contact me.**
