output "queue_url" {
  description = "URL da fila."
  value       = aws_sqs_queue.this.url
}

output "queue_arn" {
  description = "ARN da fila."
  value       = aws_sqs_queue.this.arn
}

output "queue_name" {
  description = "Nome da fila."
  value       = aws_sqs_queue.this.name
}

output "dlq_url" {
  description = "URL da DLQ (null se desabilitada)."
  value       = try(aws_sqs_queue.dlq[0].url, null)
}

output "dlq_arn" {
  description = "ARN da DLQ (null se desabilitada)."
  value       = try(aws_sqs_queue.dlq[0].arn, null)
}
