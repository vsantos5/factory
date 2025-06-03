# EKS Provisioning with Terraform

This module provisions an AWS EKS cluster and its core add-ons using Terraform and AWS EKS Blueprints. It leverages the [terraform-aws-modules/eks](https://github.com/terraform-aws-modules/terraform-aws-eks) and [aws-ia/eks-blueprints-addons](https://github.com/aws-ia/terraform-aws-eks-blueprints-addons) modules, and includes Karpenter for cluster autoscaling.

---

## Features

- **EKS Cluster**: Creates an EKS cluster with managed node groups.
- **Add-ons**: Installs core EKS add-ons (EBS CSI, CoreDNS, VPC CNI, Kube Proxy).
- **Karpenter**: Provisions Karpenter for dynamic node provisioning.
- **Helm Integration**: Installs Karpenter via Helm.
- **Subnet Tagging**: Tags subnets for Karpenter discovery.
- **Blueprint Add-ons**: Support for ArgoCD, Prometheus, Metrics Server, ExternalDNS, Cert Manager, and more.

---

## File Structure

<workload>/
  <environment>/
    app/
      *.tf                # Terraform modules and resources
    config.yaml           # Main environment configuration

---

## Usage

1. **Configure your `config.yaml`**  
   Define your EKS clusters and parameters in your workspace YAML.

---

## Main Components

### EKS Cluster

- Uses `terraform-aws-modules/eks/aws`.
- Supports managed node groups with custom instance types, capacity type (SPOT/ON_DEMAND), and scaling parameters.
- Tags security groups and subnets for Karpenter discovery.

### EKS Add-ons

- Uses `aws-ia/eks-blueprints-addons/aws`.
- Installs core add-ons (EBS CSI, CoreDNS, VPC CNI, Kube Proxy).
- Additional add-ons (ArgoCD, Prometheus, etc.).

### Karpenter

- Uses the Karpenter submodule from the EKS module.
- Installs Karpenter via Helm with required IAM roles and policies.
- Configures Karpenter to discover the cluster and subnets via tags.

### Subnet Tagging

- Automatically tags private and public subnets for Karpenter discovery.

---

## Example:

- Only required parameters are necessary for resource creation. Optional parameters can be provided for customization; if omitted, default values from the modules will be used.

```yaml
workspaces:
  dev:
    ... truncated for brevity
    eks:
      - cluster: main # REQUIRED FIELD
        cluster_version: 1.31 # REQUIRED FIELD
        instance_types: ["m6i.large", "m5.xlarge", "m5n.2xlarge"]
        capacity_type: SPOT # "SPOT" : "ON_DEMAND"
        min_cluster_size: 1
        max_cluster_size: 3
        desired_cluster_size: 1
        enable_argocd: true
        enable_kube_prometheus_stack: true
        enable_metrics_server: true
        enable_external_dns: true
        enable_cert_manager: true
```

---

## Notes

- **Cluster Add-ons**: You can customize or add more EKS add-ons as needed.

- **Karpenter**: After deployment, you may need to configure Karpenter Provisioners and EC2NodeClasses via Kubernetes manifests, see some samples on manifests folder, inside this repository.

- **ArgoCD**: After enabling, patch the ArgoCD service to LoadBalancer and retrieve the admin password as described below.
  1- After enabling ArgoCD, run the following command to change itś Service Type to LoadBalancer
  ```bash
  kubectl -n argocd patch svc argo-cd-argocd-server -p '{"spec": {"type": "LoadBalancer"}}'
  ```
  2- Get the argocd andpoint
  ```bash
  kubectl -n argocd get service argo-cd-argocd-server -o jsonpath="{.status.loadBalancer.ingress[*].hostname}{'\n'}"
  ```
  3- Get the Admin password
  ```bash
echo "$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)"
  
- **Prometheus/Grafana**: Instructions for accessing Grafana and retrieving credentials follow the instructions below.
  1- Get the username
  ```bash
  get secret kube-prometheus-stack-grafana -n kube-prometheus-stack -o jsonpath="{.data.admin-user}" | base64 -d
  ```
  2- Get the password
  ```bash
  kubectl get secret kube-prometheus-stack-grafana -n kube-prometheus-stack -o jsonpath="{.data.admin-password}" | base64 -d
  ```
  3- Create the port-forward
  ```bash
  kubectl -n kube-prometheus-stack port-forward svc/kube-prometheus-stack-grafana 50080:80
  ```
  4- Open the UI on your browser pointing to http://localhost:50080/

---

## References

- [terraform-aws-modules/eks](https://github.com/terraform-aws-modules/terraform-aws-eks)
- [aws-ia/eks-blueprints-addons](https://github.com/aws-ia/terraform-aws-eks-blueprints-addons)
- [Karpenter](https://karpenter.sh/)

---

**For questions, open an issue.**