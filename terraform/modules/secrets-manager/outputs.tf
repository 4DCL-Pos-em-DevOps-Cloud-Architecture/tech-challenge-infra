output "secret_arns" {
  description = "ARNs of the created Secrets Manager secrets."
  value       = { for name, secret in aws_secretsmanager_secret.this : name => secret.arn }
}
