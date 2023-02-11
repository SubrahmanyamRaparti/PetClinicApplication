# ---------------------------------------------------------------------------------------------------------------------
# Elastic Container Registry - ECR
# ---------------------------------------------------------------------------------------------------------------------

# Repository

resource "aws_ecr_repository" "aws_ecr_repository" {
  name                 = var.project_name
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}
