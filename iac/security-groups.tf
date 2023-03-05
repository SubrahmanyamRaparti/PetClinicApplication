# ---------------------------------------------------------------------------------------------------------------------
# Security Groups
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_security_group" "aws_security_group_endpoint" {
  name        = "${var.project_name}-endpoint"
  description = "Allow inbound traffic for interface endpoint"
  vpc_id      = aws_vpc.aws_vpc.id
  dynamic "ingress" {
    for_each = var.endpoint_interface_ports
    iterator = port
    content {
      description = "TLS from VPC"
      from_port   = port.value
      to_port     = port.value
      protocol    = "tcp"
      cidr_blocks = [aws_subnet.aws_subnet_private["A"].cidr_block, 
      aws_subnet.aws_subnet_private["B"].cidr_block]
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, local.workspace)
}