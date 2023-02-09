# ---------------------------------------------------------------------------------------------------------------------
# Code Commit
# ---------------------------------------------------------------------------------------------------------------------

# Repository

resource "aws_codecommit_repository" "aws_codecommit_repository" {
  repository_name = "PetClinicApplication"
  description     = "Pet Clinic Application Repository"
  tags            = merge(local.common_tags, local.workspace)
}

# IAM Policy & Role

data "template_file" "template_file_trigger_pipeline" {
  template = file("./templates/codecommit/CodeCommitTriggerPipelinePolicy.json")
  vars = {
    # pipeline_arn = "${aws_codepipeline.pipeline.arn}"
    pipeline_arn = "dummy"
  }
}

resource "aws_iam_policy" "aws_iam_policy_trigger_pipeline" {
  name        = "TriggerPipelinePolicy"
  path        = "/"
  description = "Trigger CICD pipeline upon commiting the code"
  policy      = data.template_file.template_file_trigger_pipeline.rendered
}

resource "aws_iam_role" "aws_iam_role_trigger_pipeline" {
  name               = "TriggerPipelineRole"
  assume_role_policy = file("./templates/codecommit/AssumeRole.json")
  tags               = merge(local.common_tags, local.workspace)
}

resource "aws_iam_role_policy_attachment" "aws_iam_role_policy_attachment_trigger_pipeline" {
  role       = aws_iam_role.aws_iam_role_trigger_pipeline.name
  policy_arn = aws_iam_policy.aws_iam_policy_trigger_pipeline.arn
}

# Cloud Watch Event Rule & Target

data "template_file" "template_file_event_pattern" {
  template = file("./templates/codecommit/CloudWatchEventPattern.json")
  vars = {
    repository_arn = aws_codecommit_repository.aws_codecommit_repository.arn
    branch_name    = var.source_repo_branch
  }
}

resource "aws_cloudwatch_event_rule" "aws_cloudwatch_event_rule" {
  name          = "TriggerPipelineEventRule"
  description   = "Trigger CICD pipeline upon commiting the code"
  event_pattern = data.template_file.template_file_event_pattern.rendered
  role_arn      = aws_iam_role.aws_iam_role_trigger_pipeline.arn
  is_enabled    = true
}

# resource "aws_cloudwatch_event_target" "aws_cloudwatch_event_target" {
#   rule      = aws_cloudwatch_event_rule.aws_cloudwatch_event_rule.name
#   target_id = "${var.source_repo_name}-${var.source_repo_branch}-pipeline"
#   arn       = aws_codepipeline.pipeline.arn
#   role_arn = aws_iam_role.aws_iam_role_trigger_pipeline.arn
# }

