variable "project_name" {
  description = "Prefix used in ECR repository names"
  type        = string
}

variable "repositories" {
  description = "Microservices that receive an ECR repository"
  type        = set(string)
  default = [
    "auth",
    "flag",
    "targeting",
    "evaluation",
    "analytics"
  ]
}

variable "tags" {
  description = "Common tags applied to ECR repositories"
  type        = map(string)
  default     = {}
}
