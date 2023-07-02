# ---------------------------------------------------------------------------------------------------------------------
# Code Deploy
# ---------------------------------------------------------------------------------------------------------------------

# IAM Policy & Role

resource "aws_iam_role" "aws_iam_role_codedeploy" {
  name               = "CodeDeployRole"
  assume_role_policy = file("./templates/codedeploy/AssumeRole.json")
  tags               = merge(local.common_tags, local.workspace)
}

resource "aws_iam_role_policy_attachment" "aws_iam_role_policy_attachment_codedeploy" {
  policy_arn = "arn:aws:iam::aws:policy/AWSCodeDeployRoleForECS"
  role       = aws_iam_role.aws_iam_role_codedeploy.name
}

# CodeDeploy

resource "aws_codedeploy_app" "aws_codedeploy_app" {
  compute_platform = "ECS"
  name             = var.project_name
  tags             = merge(local.common_tags, local.workspace)
}

resource "aws_codedeploy_deployment_group" "aws_codedeploy_deployment_group" {
  app_name              = aws_codedeploy_app.aws_codedeploy_app.name
  deployment_group_name = var.project_name
  service_role_arn      = aws_iam_role.aws_iam_role_codedeploy.arn

  ecs_service {
    cluster_name = aws_ecs_cluster.aws_ecs_cluster.name
    service_name = aws_ecs_service.aws_ecs_service.name
  }

  load_balancer_info {
    target_group_pair_info {
      prod_traffic_route {
        listener_arns = [aws_lb_listener.aws_lb_listener_blue.arn]
      }

      test_traffic_route {
        listener_arns = [aws_lb_listener.aws_lb_listener_green.arn]
      }

      target_group {
        name = aws_lb_target_group.aws_lb_target_group_blue.name
      }

      target_group {
        name = aws_lb_target_group.aws_lb_target_group_green.name
      }
    }
  }

  deployment_config_name = "CodeDeployDefault.ECSAllAtOnce"

  auto_rollback_configuration {
    enabled = true
    events  = ["DEPLOYMENT_FAILURE"]
  }

  blue_green_deployment_config {
    deployment_ready_option {
      # action_on_timeout = "CONTINUE_DEPLOYMENT"
      action_on_timeout = "STOP_DEPLOYMENT"
      wait_time_in_minutes = 5
    }

    terminate_blue_instances_on_deployment_success {
      action                           = "TERMINATE"
      termination_wait_time_in_minutes = 5
    }
  }

  deployment_style {
    deployment_option = "WITH_TRAFFIC_CONTROL"
    deployment_type   = "BLUE_GREEN"
  }
}
