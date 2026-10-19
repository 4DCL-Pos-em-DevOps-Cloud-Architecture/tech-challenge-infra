# Infraestrutura e GitOps

Este repositório centraliza a infraestrutura AWS e os manifestos Kubernetes do projeto ToggleMaster.

## 📦 Estrutura do repositório

```text
infra/
├── agroCD/                 # Aplicações Argo CD
├── gitops/                 # Manifestos Kubernetes por microsserviço
└── terraform/              # Infraestrutura como código
    ├── bootstrap/          # Configuração inicial do estado remoto
    ├── modules/             # Módulos reutilizáveis
    ├── main.tf
    ├── providers.tf
    ├── variables.tf
    └── versions.tf
```

## 📋 Pré-requisitos

- [Terraform](https://developer.hashicorp.com/terraform/install) `1.6` ou superior;
- [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html);
- Credenciais AWS configuradas, por exemplo com `aws configure`;
- Permissões para criar VPC, EKS, RDS, ElastiCache, DynamoDB, SQS e ECR;
- `kubectl` configurado para acessar o cluster EKS após sua criação;
- [Argo CD](https://argo-cd.readthedocs.io/) instalado no cluster, caso o deploy GitOps seja utilizado.

Para o ambiente AWS Academy, informe também a ARN da role disponibilizada pelo laboratório:

```text
arn:aws:iam::<ACCOUNT_ID>:role/LabRole
```

## ☁️ Recursos provisionados pelo Terraform

O projeto provisiona:

- VPC com subnets públicas e privadas;
- Internet Gateway, NAT Gateway e tabelas de rota;
- Cluster EKS e node group utilizando a `LabRole`;
- Três bancos PostgreSQL no RDS:
  - `auth`;
  - `flag`;
  - `targeting`;
- Cluster Redis no ElastiCache;
- Tabela DynamoDB para analytics;
- Fila SQS e Dead Letter Queue;
- Cinco repositórios privados no ECR:
  - `auth`;
  - `flag`;
  - `targeting`;
  - `evaluation`;
  - `analytics`.

Os repositórios ECR possuem scan de imagem no push, tags imutáveis e lifecycle policy para manter as dez imagens mais recentes.

## ⚙️ Configuração do Terraform

Entre no diretório Terraform:

```bash
cd terraform
```

Crie ou revise o arquivo `terraform.tfvars`:

```hcl
aws_region = "us-east-1"

project_name = "togglemaster"
environment  = "dev"

lab_role_arn = "arn:aws:iam::<ACCOUNT_ID>:role/LabRole"

availability_zones = [
  "us-east-1a",
  "us-east-1b"
]

public_subnet_cidrs = [
  "10.0.1.0/24",
  "10.0.2.0/24"
]

private_subnet_cidrs = [
  "10.0.11.0/24",
  "10.0.12.0/24"
]
```

Não versione credenciais, senhas ou tokens no repositório. O arquivo `terraform.tfvars` utilizado localmente deve ser revisado antes do commit.

## 🗄️ Estado remoto

O estado do Terraform não deve permanecer local em um ambiente compartilhado.

O diretório `terraform/bootstrap/state-bucket` cria o bucket utilizado pelo backend S3, usando estado local somente durante o bootstrap. O projeto principal possui o backend remoto em `terraform/backend.tf`, utilizando:

- Bucket: `togglemaster-terraform-state`;
- Região: `us-east-1`;
- Chave: `dev/terraform.tfstate`;
- Lock com `use_lockfile`;
- Criptografia habilitada.

Como o estado local pode ser descartado neste projeto, não é necessário migrá-lo. Crie primeiro o bucket:

```bash
cd terraform/bootstrap/state-bucket
terraform init
terraform apply
```

Depois inicialize o projeto principal:

```bash
cd ../../
terraform init
```

O bucket precisa existir antes desse segundo `terraform init`, pois o Terraform principal já utiliza o backend S3 desde a inicialização.

## 🔄 GitHub Actions

O workflow `/.github/workflows/terraform.yml` executa:

- `fmt`, `init`, `validate` e `plan` em Pull Requests para `main`;
- `fmt`, `init`, `validate`, `plan` e `apply` em pushes para `main`;
- o mesmo fluxo pode ser iniciado manualmente com `workflow_dispatch`.

O job de aplicação utiliza o GitHub Environment `terraform-apply`. Configure uma aprovação manual nesse environment antes de permitir a criação ou alteração da infraestrutura.

Como o projeto não utiliza OIDC, configure os seguintes secrets no repositório:

| Secret | Uso |
|---|---|
| `AWS_ACCESS_KEY_ID` | Access key da AWS |
| `AWS_SECRET_ACCESS_KEY` | Secret key da AWS |
| `AWS_SESSION_TOKEN` | Token temporário, quando exigido pelo AWS Academy |
| `LAB_ROLE_ARN` | ARN da `LabRole` utilizada pelo EKS |

Também é possível configurar a variável de repositório `AWS_REGION`. Se ela não existir, o workflow utiliza `us-east-1`.

O bucket S3 do backend precisa ser criado antes da primeira execução do workflow principal. O bootstrap não é executado automaticamente pela Action para evitar o ciclo de dependência entre o bucket e o backend remoto.

## 🚀 Executando o Terraform

Formate os arquivos:

```bash
terraform fmt -recursive
```

Inicialize o Terraform e baixe os módulos:

```bash
terraform init
```

Valide a configuração:

```bash
terraform validate
```

Gere o plano:

```bash
terraform plan -out=tfplan
```

Revise o plano e aplique a infraestrutura:

```bash
terraform apply tfplan
```

Para consultar os outputs:

```bash
terraform output
```

Para configurar o acesso ao EKS:

```bash
aws eks update-kubeconfig \
  --region us-east-1 \
  --name togglemaster-eks
```

⚠️ `terraform destroy` remove os recursos provisionados e pode gerar custos ou perda de dados. Execute somente após revisar o plano de destruição.

## 📦 ECR e pipelines

As pipelines dos cinco microsserviços fazem build, scan da imagem, login no ECR e push usando a tag do commit.

Com `project_name = "togglemaster"`, os repositórios esperados são:

```text
<ACCOUNT_ID>.dkr.ecr.us-east-1.amazonaws.com/togglemaster-auth-service
<ACCOUNT_ID>.dkr.ecr.us-east-1.amazonaws.com/togglemaster-flag-service
<ACCOUNT_ID>.dkr.ecr.us-east-1.amazonaws.com/togglemaster-targeting-service
<ACCOUNT_ID>.dkr.ecr.us-east-1.amazonaws.com/togglemaster-evaluation-service
<ACCOUNT_ID>.dkr.ecr.us-east-1.amazonaws.com/togglemaster-analytics-service
```

Substitua `<ACCOUNT_ID>` pela conta AWS utilizada e mantenha os nomes dos repositórios iguais nas pipelines e nos deployments Kubernetes.

## ☸️ GitOps e Kubernetes

Os manifestos estão organizados por microsserviço em `gitops/`:

```text
gitops/
├── auth-service/
├── flag-service/
├── targeting-service/
├── evaluation-service/
└── analytics-service/
```

Cada diretório contém seu próprio `kustomization.yaml`, namespace, deployment, service e demais recursos necessários.

Antes da aplicação, revise e substitua os placeholders:

| Placeholder | Descrição |
|---|---|
| `<ACCOUNT_ID>` | ID da conta AWS |
| `<REGISTRY_URL>` | URI base do ECR |
| `<IMAGE_TAG>` | Tag da imagem publicada, normalmente o hash do commit |
| `<DATABASE_URL>` | String de conexão do PostgreSQL correspondente |
| `<SERVICE_API_KEY>` | Chave de API usada pelo microsserviço |
| `<AWS_SQS_URL>` | URL da fila SQS |
| `<AWS_DYNAMODB_TABLE>` | Nome da tabela DynamoDB |
| `<REDIS_ENDPOINT>` | Endpoint privado do Redis |

Não versione valores reais de `Secret` no repositório.

Para aplicar um serviço manualmente com Kustomize:

```bash
kubectl apply -k gitops/auth-service
kubectl apply -k gitops/flag-service
kubectl apply -k gitops/targeting-service
kubectl apply -k gitops/evaluation-service
kubectl apply -k gitops/analytics-service
```

Para instalar as aplicações Argo CD:

```bash
kubectl apply -f agroCD/agrocd-applications.yaml
```

O Argo CD acompanhará os diretórios definidos no arquivo de aplicações e fará a sincronização automática conforme configurado.

## 🔐 Segurança

- Não versione credenciais AWS, senhas, chaves de API ou valores reais de Secrets;
- Prefira Secrets Manager, External Secrets ou outro mecanismo seguro para valores sensíveis;
- Os bancos RDS e Redis são configurados como privados;
- Restrinja Security Groups ao menor conjunto de origens necessário;
- Mantenha as tags imutáveis do ECR para evitar sobrescrita acidental de imagens;
- Revise sempre o resultado de `terraform plan` antes do `apply`.

