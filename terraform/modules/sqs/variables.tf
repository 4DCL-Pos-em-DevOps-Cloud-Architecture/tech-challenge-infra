variable "name" {
  description = "Nome da fila principal (ex: togglemaster-dev-events)."
  type        = string
}

variable "visibility_timeout_seconds" {
  description = "Tempo em que a mensagem fica invisivel apos ser lida."
  type        = number
  default     = 30
}

variable "message_retention_seconds" {
  description = "Retencao das mensagens na fila principal (padrao: 4 dias)."
  type        = number
  default     = 345600
}

variable "receive_wait_time_seconds" {
  description = "Long polling (0-20s)."
  type        = number
  default     = 20
}

variable "max_message_size" {
  description = "Tamanho maximo da mensagem em bytes."
  type        = number
  default     = 262144
}

variable "enable_dlq" {
  description = "Cria uma Dead Letter Queue."
  type        = bool
  default     = true
}

variable "max_receive_count" {
  description = "Tentativas de leitura antes de enviar a mensagem para a DLQ."
  type        = number
  default     = 5
}

variable "dlq_message_retention_seconds" {
  description = "Retencao das mensagens na DLQ (padrao: 14 dias)."
  type        = number
  default     = 1209600
}

variable "tags" {
  description = "Tags aplicadas aos recursos."
  type        = map(string)
  default     = {}
}
