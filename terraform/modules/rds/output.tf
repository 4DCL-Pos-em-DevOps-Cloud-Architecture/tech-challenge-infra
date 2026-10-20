output "rds_endpoints" {
  description = "RDS endpoints for each database instance"
  value       = { for db_name, db in module.rds : db_name => db.db_instance_endpoint }
}

output "rds_passwords" {
  description = "Generated master passwords for each database"
  sensitive   = true
  value       = { for db_name, db in module.rds : db_name => db.db_instance_password }
}
