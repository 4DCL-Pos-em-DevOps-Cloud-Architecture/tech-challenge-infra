output "table_name" {
  description = "Nome da tabela DynamoDB"
  value       = module.dynamodb.dynamodb_table_id
}

output "table_arn" {
  description = "ARN da tabela DynamoDB"
  value       = module.dynamodb.dynamodb_table_arn
}

output "table_id" {
  description = "ID da tabela DynamoDB"
  value       = module.dynamodb.dynamodb_table_id
}
