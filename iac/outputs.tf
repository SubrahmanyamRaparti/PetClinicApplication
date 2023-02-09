output "aws_codecommit_repository_arn" {
  value = resource.aws_codecommit_repository.aws_codecommit_repository.arn
}

output "workspace" {
  value = local.workspace.environment
}

