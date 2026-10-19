locals {
  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "terraform"
  }
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
  lab_role_arn       = var.lab_role_arn
  tags               = local.common_tags
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

output "sqs_queue_url" {
  value = module.sqs.queue_url
}

output "sqs_queue_arn" {
  value = module.sqs.queue_arn
}

output "ecr_repository_urls" {
  value = module.ecr.repository_urls
}
