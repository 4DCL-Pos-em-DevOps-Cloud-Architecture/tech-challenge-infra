module "redis" {
  source  = "terraform-aws-modules/elasticache/aws"
  version = "~> 1.0"

  replication_group_id = var.name
  description          = "Redis cluster for ${var.name}"
  engine               = var.engine
  engine_version       = var.engine_version
  node_type            = var.node_type
  num_cache_clusters   = var.number_cache_nodes
  parameter_group_name = var.parameter_group_name
  port                 = var.port

  create_subnet_group   = false
  subnet_group_name     = var.subnet_group_name
  security_group_ids    = var.security_group_ids
  create_security_group = false

  transit_encryption_enabled = true

  tags = var.tags
}
