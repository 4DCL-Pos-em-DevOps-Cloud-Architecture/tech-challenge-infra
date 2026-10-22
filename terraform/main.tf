data "aws_caller_identity" "current" {}

locals {
  lab_role_arn = var.lab_role_arn != "" ? var.lab_role_arn : "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${var.lab_role_name}"
  master_key   = var.master_key != "" ? var.master_key : random_password.master_key.result

  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

resource "random_password" "master_key" {
  length  = 48
  special = false
}

module "networking" {
  source = "./modules/networking"

  name                 = var.cluster_name
  environment          = var.environment
  vpc_cidr             = var.vpc_cidr
  availability_zones   = var.availability_zones
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  tags                 = local.common_tags
}

module "eks" {
  source = "./modules/eks"

  cluster_name       = var.cluster_name
  cluster_version    = var.cluster_version
  environment        = var.environment
  vpc_id             = module.networking.vpc_id
  private_subnet_ids = module.networking.private_subnet_ids

  lab_role_arn = local.lab_role_arn
  tags         = local.common_tags
}

module "sqs" {
  source = "./modules/sqs"

  name = "${var.project_name}-${var.environment}-events"

  tags = local.common_tags
}

module "rds" {
  source = "./modules/rds"

  db_engine            = var.db_engine
  db_engine_version    = var.db_engine_version
  db_instance_class    = var.db_instance_class
  db_allocated_storage = var.db_allocated_storage

  private_subnet_ids   = module.networking.private_subnet_ids
  db_security_group_id = module.networking.db_security_group_id
  db_master_username   = var.db_master_username

  environment = var.environment
  tags        = local.common_tags
}

module "secrets_manager" {
  source = "./modules/secrets-manager"

  project_name = var.project_name
  environment  = var.environment
  tags         = local.common_tags

  secrets = merge(
    {
      for db_name, endpoint in module.rds.rds_endpoints : "${db_name}/database" => {
        description = "Connection data for the ${db_name} database"
        value = jsonencode({
          DATABASE_URL = "postgresql://${var.db_master_username}:${module.rds.rds_passwords[db_name]}@${endpoint}/postgres"
        })
      }
    },
    {
      "auth/application" = {
        description = "Application secrets for the auth service"
        value = jsonencode({
          MASTER_KEY = local.master_key
        })
      }
    },
    var.enable_evaluation_secret ? {
      "evaluation/application" = {
        description = "Application secrets for the evaluation service"
        value = jsonencode({
          SERVICE_API_KEY = var.service_api_key
        })
      }
    } : {}
  )
}


module "dynamodb" {
  source = "./modules/dynamodb"

  name = "${var.project_name}-${var.environment}-analytics"

  tags = local.common_tags
}

module "redis" {
  source = "./modules/redis"

  name               = "${var.project_name}-${var.environment}-redis"
  engine_version     = var.redis_engine_version
  node_type          = var.redis_node_type
  number_cache_nodes = var.redis_number_cache_nodes
  subnet_group_name  = module.networking.redis_subnet_group_name
  security_group_ids = [module.networking.redis_security_group_id]
  tags               = local.common_tags
}

module "ecr" {
  source = "./modules/ecr"

  project_name = var.project_name
  tags         = local.common_tags
}

provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_name]
  }
}

provider "helm" {
  kubernetes = {
    host = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(
      module.eks.cluster_certificate_authority_data
    )

    exec = {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_name]
    }
  }
}

resource "kubernetes_namespace" "argocd" {
  metadata {
    name = "argocd"
  }
}

resource "helm_release" "argocd" {
  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  namespace  = kubernetes_namespace.argocd.metadata[0].name
  version    = "5.46.0"

  values = [<<EOT
server:
  service:
    type: LoadBalancer
  extraArgs:
    - --insecure
EOT
  ]
}

resource "kubernetes_manifest" "argocd_applications" {
  depends_on = [helm_release.argocd]

  manifest = yamldecode(file("${path.module}/../agroCD/argocd-applications.yaml"))
}

output "sqs_queue_url" {
  value = module.sqs.queue_url
}

output "sqs_queue_arn" {
  value = module.sqs.queue_arn
}


output "ecr_repository_urls" {
  value = module.ecr.repository_urls
}


output "secret_arns" {
  description = "ARNs of application and database secrets"
  value       = module.secrets_manager.secret_arns
}

output "argocd_server_url" {
  description = "URL publica para acessar a interface do ArgoCD gerada pelo LoadBalancer da AWS"
  value       = "http://${try(data.kubernetes_service.argocd_server_lb.status[0].load_balancer[0].ingress[0].hostname, "Aguardando provisionamento do LoadBalancer...")}"
}

data "kubernetes_service" "argocd_server_lb" {
  depends_on = [helm_release.argocd]
  metadata {
    name      = "argocd-server"
    namespace = kubernetes_namespace.argocd.metadata[0].name
  }
}

output "rds_passwords" {
  sensitive = true
  value     = module.rds.rds_passwords
}
