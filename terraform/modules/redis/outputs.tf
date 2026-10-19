output "replication_group_id" {
  description = "Redis replication group identifier"
  value       = module.redis.replication_group_id
}

output "primary_endpoint_address" {
  description = "Primary Redis endpoint"
  value       = module.redis.replication_group_primary_endpoint_address
}

output "port" {
  description = "Redis port"
  value       = module.redis.replication_group_port
}
