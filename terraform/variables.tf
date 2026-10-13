variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "lab_role_arn" {
  type      = string
  sensitive = true
}

variable "cluster_name" {
  type    = string
  default = "togglemaster-eks"
}

variable "environment" {
  type    = string
  default = "dev"
}

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "availability_zones" {
  type = list(string)
}

variable "public_subnet_cidrs" {
  type = list(string)
}

variable "private_subnet_cidrs" {
  type = list(string)
}

variable "cluster_version" {
  type    = string
  default = "1.21"
}

variable "project_name" {
  type = string
}
