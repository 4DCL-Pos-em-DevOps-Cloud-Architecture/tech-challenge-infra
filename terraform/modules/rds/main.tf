module "rds" {
  source  = "terraform-aws-modules/rds/aws"
  version = "~> 5.0"

  for_each = toset(["auth", "flag", "targeting"])

  identifier     = "togglemaster-${each.value}"
  engine         = var.db_engine
  engine_version = var.db_engine_version
  family         = "postgres15"

  instance_class    = var.db_instance_class
  allocated_storage = var.db_allocated_storage

  subnet_ids = var.private_subnet_ids

  vpc_security_group_ids = [var.db_security_group_id]

  username               = var.db_master_username
  create_random_password = true

  multi_az            = false
  publicly_accessible = false

  tags = var.tags
}
