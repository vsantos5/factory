# Provisionamento de Infra AWS com config.yaml

Este repositório provisiona infraestrutura AWS usando Terraform, orientado por um arquivo de configuração YAML. Todos os ambientes e recursos são definidos no `config.yaml`, facilitando o gerenciamento e a replicação da infraestrutura em diversos ambientes.

Algumas informações perssonalizadas, também precisam ser parametrizadas no `locals.tf`. Lembrando que as regras de Security Group devem ser perssonalizadas no arquivo `security_groups.tf` de acordo com as necessidades de cada cenário.

---

## Índice

- [Visão Geral](#visão-geral)
- [Estrutura de Pastas](#estrutura-de-pastas)
- [Como funciona o config.yaml](#como-funciona-o-configyaml)
- [Recursos Suportados](#recursos-suportados)
- [Instruções de Uso](#instruções-de-uso)
- [Exemplo: Adicionando um Novo Serviço](#exemplo-adicionando-um-novo-serviço)
- [Dicas & Solução de Problemas](#dicas--solução-de-problemas)

---

## Visão Geral

- Todos os recursos AWS (VPC, ALB, ECS, EFS, EKS, CloudFront, etc.) são definidos em um único arquivo YAML que servirá de parâmetro para a criação dos recursos.
- O Terraform lê esse arquivo e usa as informações para criar os recursos dinamicamente.
- A abordagem suporta múltiplos ambientes (dev, prod, etc.) ou os ambientes também podem ser criados separadamente.

---

## Estrutura de Pastas

```
<workload>/
  <ambiente>/
    app/
      *.tf                # Módulos e recursos Terraform
    config.yaml           # Configuração principal do ambiente
    shared/
      config.yaml         # Configurações de VPC
```

---

## Como funciona o config.yaml

- O arquivo é estruturado por workspaces (ex: `dev`, `qa`, `prod`).
- Cada seção (ex: `alb`, `ecs`, `efs`, `eks`, `cloudfront`) lista recursos e seus parâmetros.
- Somente os parâmetros obrigatórios são requisitos para a criação dos recursos. Os parâmetros opcionais podem ser informados, caso deseje alguma perssonalização ou se não forem informados, serão criados com os valores definidos nos módulos.

**Exemplo:**
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

## Recursos Suportados

- **VPC**: Definido em `shared/config.yaml`
- **ALB**: Application Load Balancers (privado/público)
- **CloudFront**: Distribuições utilizando buckets S3
- **ECS**: Clusters e serviços ECS
- **EFS**: Elastic File Systems
- **EKS**: Clusters Kubernetes
- **S3**: Buckets S3 privados
- **SSM**: Armazenamento de parâmetros

---

## Instruções de Uso

1. **Edite o `config.yaml`**  
   Atualize ou adicione recursos no workspace apropriado (ex: `dev`).
   Informe os valores dos parâmetros para criação dos recursos
   Caso não precise que o recurso seja criado, basta passar o parametro chave como uma lista vazia [].

2. **Inicialize o Terraform**  
   ```bash
   terraform init
   ```

3. **Planeje o Deploy**  
   ```bash
   terraform plan
   ```

4. **Aplique o Deploy**  
   ```bash
   terraform apply
   ```

5. **Destrua os Recursos (se necessário)**  
   ```bash
   terraform destroy
   ```

---

## Exemplo: Adicionando Novos Serviços

1. No `dev/config.yaml`:
   ```yaml
   workspaces:
    dev:
      alb:
        # ECS/EKS uses the private ALB to route traffic to the services.
        # IF deleted the ECS will not work.
        # Dont change the private ALB name, it is used on other modules.
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
        #ECS/EKS uses the public ALB to route traffic to the services.
        #IF deleted the ECS will not work.
        #Dont change the public ALB name, it is used on other modules.
        - name: public # # REQUIRED FIELD
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
      # Before to create the EKS clsuter, you need to uncomment the kubernets/ helm providers on `providers.tf`
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
2. Execute `terraform plan` e `terraform apply` como acima.

---

## Dicas & Solução de Problemas

- **Arrays Vazios**: Use `[]` para espaços não utilizados, mas remova ou preencha para provisionamento real.
- **Sintaxe YAML**: Garanta indentação correta e sem vírgulas no final das linhas.
- **Múltiplos Ambientes**: Duplique o bloco `dev` como `prod`, `staging`, etc.
- **Recursos Compartilhados**: Use `shared/config.yaml` para os recursos de VPC e rede.
- **Mapeamento de Recursos**: A ordem dos itens nos arrays (ex: `alb[0]`, `alb[1]`) importa para o mapeamento de recursos privados/públicos no Terraform.

---

## Referências

- [Terraform AWS Modules](https://github.com/terraform-aws-modules)
- [Guia de Sintaxe YAML](https://yaml.org/spec/1.2/spec.html)

---

**Para dúvidas, abra uma issue ou contate o time de Responsável.**