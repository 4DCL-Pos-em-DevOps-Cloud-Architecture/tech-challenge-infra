module "ecr" {
  source  = "terraform-aws-modules/ecr/aws"
  version = "~> 3.0"

  for_each = var.repositories

  repository_name = "${var.project_name}-${each.value}-service"

  repository_image_scan_on_push   = true
  repository_image_tag_mutability = "IMMUTABLE"
  repository_force_delete         = false

  repository_lifecycle_policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Manter somente as 10 imagens mais recentes"
        selection = {
          tagStatus   = "any"
          countType   = "imageCountMoreThan"
          countNumber = 10
        }
        action = {
          type = "expire"
        }
      }
    ]
  })

  tags = merge(var.tags, {
    Service = each.value
  })
}
