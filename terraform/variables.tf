variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "lab_role_arn" {
  type    = string
  default = ""
}

variable "lab_role_name" {
  type    = string
  default = "LabRole"
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
  default = "1.34"
}

variable "project_name" {
  type = string
}

variable "db_engine" {
  type    = string
  default = "postgres"
}

variable "db_engine_version" {
  type    = string
  default = "15"
}

variable "db_instance_class" {
  type    = string
  default = "db.t3.micro"
}

variable "db_allocated_storage" {
  type    = number
  default = 20
}

variable "db_master_username" {
  type    = string
  default = "toggleadmin"
}

variable "redis_engine_version" {
  type    = string
  default = "6.x"
}

variable "redis_node_type" {
  type    = string
  default = "cache.t3.micro"
}

variable "redis_number_cache_nodes" {
  type    = number
  default = 1
}
