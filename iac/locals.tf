locals {
  common_tags = {
    "Owner"        = "Subrahmanyam"
    "Project Name" = "Pet Clinic Application"
  }

  workspace = {
    "environment" = terraform.workspace
  }
}

