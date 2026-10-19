variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "state_bucket_name" {
  type    = string
  default = "togglemaster-terraform-state-123456"
}

variable "project_name" {
  type    = string
  default = "togglemaster"
}

variable "environment" {
  type    = string
  default = "dev"
}
