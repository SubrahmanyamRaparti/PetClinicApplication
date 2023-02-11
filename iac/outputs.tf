output "aws_codecommit_repository_arn" {
  value = resource.aws_codecommit_repository.aws_codecommit_repository.arn
}

output "workspace" {
  value = local.workspace.environment
}

output "image_repo_url" {
  value = aws_ecr_repository.aws_ecr_repository.repository_url
}

output "image_repo_arn" {
  value = aws_ecr_repository.aws_ecr_repository.arn
}

