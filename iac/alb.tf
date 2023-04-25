# ---------------------------------------------------------------------------------------------------------------------
# Application Load Balancer
# ---------------------------------------------------------------------------------------------------------------------

# S3 Bucket ALB logs

resource "aws_s3_bucket" "aws_s3_bucket_alb" {
  bucket = var.s3_bucket_alb_name
}

# resource "aws_s3_bucket_acl" "aws_s3_bucket_acl_alb" {
#   bucket = aws_s3_bucket.aws_s3_bucket_alb.id
#   acl    = "private"
# }

# ALB

resource "aws_lb" "aws_lb" {
  name               = var.project_name
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.aws_security_group_alb.id]
  subnets = [aws_subnet.aws_subnet_public["A"].id,
  aws_subnet.aws_subnet_public["B"].id]

  enable_deletion_protection = false

  # access_logs {
  #   bucket  = aws_s3_bucket.aws_s3_bucket_alb.id
  #   prefix  = "${local.workspace.environment}-lb"
  #   enabled = true
  # }

  tags = merge(local.common_tags, local.workspace)
}

# ALB Target Group

resource "aws_lb_target_group" "aws_lb_target_group" {
  name                 = var.project_name
  port                 = var.container_port
  protocol             = "HTTP"
  deregistration_delay = 300
  target_type          = "ip"
  vpc_id               = aws_vpc.aws_vpc.id

  tags = merge(local.common_tags, local.workspace)
}

# ALB Listener

resource "aws_lb_listener" "aws_lb_listener" {
  load_balancer_arn = aws_lb.aws_lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.aws_lb_target_group.arn
  }

  tags = merge(local.common_tags, local.workspace)
}