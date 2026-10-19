output "rds_endpoints" {
  description = "RDS endpoints for each database instance"
  value       = { for db_name, db in module.rds : db_name => db.endpoint }
}