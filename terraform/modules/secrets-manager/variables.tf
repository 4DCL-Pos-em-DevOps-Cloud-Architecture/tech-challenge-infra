variable "project_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "secrets" {
  description = "Secrets to create, indexed by their final path suffix."
  type = map(object({
    description = string
    value       = string
  }))
  sensitive = true
}

variable "recovery_window_in_days" {
  type    = number
  default = 0
}

variable "tags" {
  type    = map(string)
  default = {}
}
