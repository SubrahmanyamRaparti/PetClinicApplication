# ---------------------------------------------------------------------------------------------------------------------
# Code Pipeline
# ---------------------------------------------------------------------------------------------------------------------

# IAM Policy & Role

data "template_file" "template_file_pipeline" {
  template = file("./templates/codepipeline/CodePipelinePolicy.json")
  vars = {
    s3_bucket_artifact_arn = aws_s3_bucket.aws_s3_bucket_artifact.arn
    codecommit_arn         = aws_codecommit_repository.aws_codecommit_repository.arn
  }
}

resource "aws_iam_policy" "aws_iam_policy_pipeline" {
  name        = "CodePipelinePolicy"
  path        = "/"
  description = "Pipeline"
  policy      = data.template_file.template_file_pipeline.rendered
}

resource "aws_iam_role" "aws_iam_role_pipeline" {
  name               = "CodePipelineRole"
  assume_role_policy = file("./templates/codepipeline/AssumeRole.json")
  tags               = merge(local.common_tags, local.workspace)
}

resource "aws_iam_role_policy_attachment" "aws_iam_role_policy_attachment_pipeline" {
  role       = aws_iam_role.aws_iam_role_pipeline.name
  policy_arn = aws_iam_policy.aws_iam_policy_pipeline.arn
}

# Code Pipeline

resource "aws_codepipeline" "codepipeline" {
  name     = var.project_name
  role_arn = aws_iam_role.aws_iam_role_pipeline.arn

  artifact_store {
    location = aws_s3_bucket.aws_s3_bucket_artifact.bucket
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeCommit"
      version          = "1"
      run_order        = 1
      output_artifacts = ["source_output"]

      configuration = {
        BranchName           = var.source_repo_branch
        PollForSourceChanges = "false" # As we are using cloud watch to trigger the pipeline.
        RepositoryName       = var.project_name
      }
    }
  }

  stage {
    name = "Build"

    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["source_output"]
      output_artifacts = ["build_output"]
      version          = "1"
      run_order        = 1

      configuration = {
        ProjectName = aws_codebuild_project.aws_codebuild_project.id
      }
    }
  }

  stage {
    name = "Deploy"

    action {
      name            = "Deploy"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "ECS"
      input_artifacts = ["build_output"]
      version         = "1"
      run_order       = 1

      configuration = {
        ClusterName = "${var.project_name}-cluser"
        ServiceName = "${var.project_name}-service"
        FileName : "imagedefinitions.json"
        DeploymentTimeout = "15"
      }
    }
  }
}