variable "name" {
  description = "Name of the Redis replication group"
  type        = string
}

variable "engine" {
  description = "The Redis engine type"
  type        = string
  default     = "redis"
}

variable "engine_version" {
  description = "The Redis engine version"
  type        = string
  default     = "6.x"
}

variable "node_type" {
  description = "The instance type of the Redis nodes"
  type        = string
  default     = "cache.t3.micro"
}

variable "number_cache_nodes" {
  description = "The number of cache clusters"
  type        = number
  default     = 1
}

variable "parameter_group_name" {
  description = "The name of the parameter group to associate with the Redis cluster"
  type        = string
  default     = "default.redis6.x"
}

variable "port" {
  description = "The port on which the Redis server will listen"
  type        = number
  default     = 6379
}

variable "subnet_group_name" {
  description = "The name of the subnet group to associate with the Redis cluster"
  type        = string
}

variable "security_group_ids" {
  description = "A list of security group IDs to associate with the Redis cluster"
  type        = list(string)
}

variable "tags" {
  description = "Tags applied to Redis resources"
  type        = map(string)
  default     = {}
}

