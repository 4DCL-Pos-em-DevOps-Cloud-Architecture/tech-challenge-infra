output "repository_urls" {
  description = "ECR repository URLs indexed by microservice"
  value = {
    for service, repository in module.ecr : service => repository.repository_url
  }
}

output "repository_arns" {
  description = "ECR repository ARNs indexed by microservice"
  value = {
    for service, repository in module.ecr : service => repository.repository_arn
  }
}
