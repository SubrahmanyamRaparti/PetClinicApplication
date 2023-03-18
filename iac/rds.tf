# ---------------------------------------------------------------------------------------------------------------------
# Relational Database Service
# ---------------------------------------------------------------------------------------------------------------------

# RDS - Subnet Groups
resource "aws_db_subnet_group" "aws_db_subnet_group" {
  # for_each       = var.private_cidr
  name = var.project_name
  subnet_ids = [aws_subnet.aws_subnet_private["A"].id,
  aws_subnet.aws_subnet_private["B"].id]

  tags = merge(local.common_tags, local.workspace)
}

# RDS - MYSQL
resource "aws_db_instance" "aws_db_instance" {

  engine                                = "mysql"
  engine_version                        = "8.0"
  # multi_az                              = true
  identifier                            = var.project_name
  username                              = var.database_username
  password                              = data.aws_ssm_parameter.dbpassword.value
  instance_class                        = var.db_instance_type
  storage_type                          = lookup(var.storage_type, local.workspace.environment, "development")
  allocated_storage                     = 20
  max_allocated_storage                 = 30
  network_type                          = "IPV4"
  db_subnet_group_name                  = aws_db_subnet_group.aws_db_subnet_group.id
  publicly_accessible                   = false
  vpc_security_group_ids                = [aws_security_group.aws_security_group_database.id]
  port                                  = var.db_port
  # performance_insights_enabled          = true # applicable - Standard classes (includes m classes) & Memory optimized classes (includes r and x classes)
  # performance_insights_retention_period = 7    # applicable - Standard classes (includes m classes) & Memory optimized classes (includes r and x classes)
  db_name                               = var.family
  parameter_group_name                  = "default.mysql8.0"
  storage_encrypted                     = true
  enabled_cloudwatch_logs_exports       = ["audit", "error", "general", "slowquery"]
  skip_final_snapshot                   = true
  availability_zone                     = var.db_availability_zone  # Requesting a specific availability zone is not valid for Multi-AZ instances.
  apply_immediately = false
}

data "aws_ssm_parameter" "dbpassword" {
  name = "/database/password"
}
