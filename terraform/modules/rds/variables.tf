variable "db_engine" {
  type    = string
  default = "postgres"
}

variable "db_engine_version" {
  type    = string
  default = "15.3"
}

variable "db_instance_class" {
  type    = string
  default = "db.t3.micro"
}

variable "db_allocated_storage" {
  type    = number
  default = 20
}

variable "db_security_group_id" {
  type = string
}

variable "private_subnet_ids" {
  type = list(string)
}

variable "db_master_username" {
  type      = string
  sensitive = true
}

variable "environment" {
  type = string
}

variable "tags" {
  type    = map(string)
  default = {}
}
