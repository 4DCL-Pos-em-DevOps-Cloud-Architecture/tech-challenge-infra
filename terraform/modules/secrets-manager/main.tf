resource "aws_secretsmanager_secret" "this" {
  for_each = nonsensitive(toset(keys(var.secrets)))

  name                    = "${var.project_name}/${var.environment}/${each.value}"
  description             = var.secrets[each.value].description
  recovery_window_in_days = var.recovery_window_in_days

  tags = var.tags
}

resource "aws_secretsmanager_secret_version" "this" {
  for_each = nonsensitive(toset(keys(var.secrets)))

  secret_id     = aws_secretsmanager_secret.this[each.value].id
  secret_string = var.secrets[each.value].value
}
