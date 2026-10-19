output "vpc_id" {
  value = aws_vpc.this.id
}

output "public_subnet_ids" {
  value = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  value = aws_subnet.private[*].id
}

output "db_security_group_id" {
  value = aws_security_group.db.id
}

output "redis_subnet_group_name" {
  value = aws_elasticache_subnet_group.redis.name
}

output "redis_security_group_id" {
  value = aws_security_group.redis.id
}
