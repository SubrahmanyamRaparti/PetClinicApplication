# ---------------------------------------------------------------------------------------------------------------------
# Code Build
# ---------------------------------------------------------------------------------------------------------------------

# S3 Bucket Artifact

resource "aws_s3_bucket" "aws_s3_bucket_artifact" {
  bucket = var.s3_bucket_artifact_name
}

# resource "aws_s3_bucket_acl" "aws_s3_bucket_acl_artifact" {
#   bucket = aws_s3_bucket.aws_s3_bucket_artifact.id
#   acl    = "private"
# }

# S3 Bucket Cache

resource "aws_s3_bucket" "aws_s3_bucket_cache" {
  bucket = var.s3_bucket_cache_name
}

# resource "aws_s3_bucket_acl" "aws_s3_bucket_acl_cache" {
#   bucket = aws_s3_bucket.aws_s3_bucket_cache.id
#   acl    = "private"
# }

# IAM Policy & Role

data "template_file" "template_file_build" {
  template = file("./templates/codebuild/CodeBuildPolicy.json")
  vars = {
    s3_bucket_artifact_arn = aws_s3_bucket.aws_s3_bucket_artifact.arn
    s3_bucket_cache_arn    = aws_s3_bucket.aws_s3_bucket_cache.arn
    ecr_repository_arn     = aws_ecr_repository.aws_ecr_repository.arn
  }
}

resource "aws_iam_policy" "aws_iam_policy_build" {
  name        = "CodeBuildPolicy"
  path        = "/"
  description = "Build the source code"
  policy      = data.template_file.template_file_build.rendered
}

resource "aws_iam_role" "aws_iam_role_build" {
  name               = "CodeBuildRole"
  assume_role_policy = file("./templates/codebuild/AssumeRole.json")
  tags               = merge(local.common_tags, local.workspace)
}

resource "aws_iam_role_policy_attachment" "aws_iam_role_policy_attachment_build" {
  role       = aws_iam_role.aws_iam_role_build.name
  policy_arn = aws_iam_policy.aws_iam_policy_build.arn
}

# Code Build

data "template_file" "template_file_buildspec" {
  template = file("./templates/codebuild/Buildspec.yaml")
  vars = {
    aws_account_id = data.aws_caller_identity.current.account_id
    aws_region     = data.aws_region.current.name
  }
}

resource "aws_codebuild_project" "aws_codebuild_project" {
  # depends_on = [
  #   aws_codecommit_repository.aws_codecommit_repository,
  #   aws_ecr_repository.aws_ecr_repository
  # ]

  name           = var.project_name
  description    = "Build the source code"
  build_timeout  = "5"
  service_role   = aws_iam_role.aws_iam_role_build.arn
  source_version = var.source_repo_branch

  artifacts {
    type = "CODEPIPELINE" # If type is set to CODEPIPELINE, AWS CodePipeline ignores this value if specified. This is because CodePipeline manages its build output locations instead of CodeBuild.
  }

  cache {
    type     = "S3"
    location = aws_s3_bucket.aws_s3_bucket_cache.bucket
  }

  environment {
    compute_type                = "BUILD_GENERAL1_MEDIUM"      # Use up to 7 GB memory and 4 vCPUs for builds.
    image                       = "aws/codebuild/standard:6.0" # Ubuntu 22.04
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode             = true

    environment_variable {
      name  = "REPOSITORY_URI"
      value = aws_ecr_repository.aws_ecr_repository.repository_url
    }
    environment_variable {
      name  = "AWS_DEFAULT_REGION"
      value = data.aws_region.current.name
    }
    environment_variable {
      name  = "CONTAINER_NAME"
      value = var.family
    }
    environment_variable {
      name  = "AWS_FARGATE_CPU"
      value = var.fargate_cpu
    }
    environment_variable {
      name  = "AWS_FARGATE_MEMORY"
      value = var.fargate_memory
    }
    environment_variable {
      name  = "CONTAINER_PORT"
      value = var.container_port
    }
    environment_variable {
      name  = "DATABASE_USERNAME"
      value = var.database_username
    }
    environment_variable {
      name  = "DATABASE_ADDRESS"
      value = aws_db_instance.aws_db_instance.address
    }
    environment_variable {
      name  = "DATABASE_PROFILE"
      value = aws_db_instance.aws_db_instance.engine
    }
    environment_variable {
      name  = "DATABASE_NAME"
      value = var.family
    }
    environment_variable {
      name  = "DATABASE_PASSWORD"
      value = data.aws_ssm_parameter.dbpassword.value
    }
    environment_variable {
      name  = "CW_LOG_GROUP"
      value = var.cw_log_group
    }
    environment_variable {
      name  = "CW_LOG_STREAM"
      value = var.cw_log_stream
    }
    environment_variable {
      name  = "AWS_EXECUTION_ROLE_ARN"
      value = aws_iam_role.aws_iam_role_fargate.arn
    }
    environment_variable {
      name  = "AWS_ACCOUNT_ID"
      value = data.aws_caller_identity.current.account_id
    }
  }

  logs_config {
    cloudwatch_logs {
      group_name  = "${var.project_name}-log-group"
      stream_name = "${var.project_name}-log-stream"
    }

    s3_logs {
      status   = "ENABLED"
      location = "${aws_s3_bucket.aws_s3_bucket_artifact.id}/build-log"
    }
  }

  source {
    type            = "CODEPIPELINE"
    git_clone_depth = 1
    buildspec       = data.template_file.template_file_buildspec.rendered

  }

  tags = merge(local.common_tags, local.workspace)
}
