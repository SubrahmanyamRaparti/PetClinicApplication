# ---------------------------------------------------------------------------------------------------------------------
# Virtual Private Cloud
# ---------------------------------------------------------------------------------------------------------------------

# VPC

resource "aws_vpc" "aws_vpc" {

  cidr_block                           = var.cidr_block
  instance_tenancy                     = "default"
  enable_dns_support                   = true
  enable_network_address_usage_metrics = true # Explanation https://docs.aws.amazon.com/vpc/latest/userguide/network-address-usage.html
  enable_dns_hostnames                 = true
  tags                                 = merge(local.common_tags, local.workspace, { "Name" = var.project_name })
}

# Public Subnet

resource "aws_subnet" "aws_subnet_public" {
  for_each          = var.public_cidr
  vpc_id            = aws_vpc.aws_vpc.id
  cidr_block        = each.value[0]
  availability_zone = data.aws_availability_zones.available.names[each.value[1]]
  tags              = merge(local.common_tags, local.workspace, { "Name" = "${var.project_name}-public-${each.key}" })
}

# Private Subnet

resource "aws_subnet" "aws_subnet_private" {
  for_each          = var.private_cidr
  vpc_id            = aws_vpc.aws_vpc.id
  cidr_block        = each.value[0]
  availability_zone = data.aws_availability_zones.available.names[each.value[1]]
  tags              = merge(local.common_tags, local.workspace, { "Name" = "${var.project_name}-private-${each.key}" })
}

# Internet Gateway

resource "aws_internet_gateway" "aws_internet_gateway" {
  vpc_id = aws_vpc.aws_vpc.id

  tags = merge(local.common_tags, local.workspace, { "Name" = var.project_name })
}

# Route Table For Public Subnets

resource "aws_route_table" "aws_route_table_public" {
  vpc_id = aws_vpc.aws_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.aws_internet_gateway.id
  }

  tags = merge(local.common_tags, local.workspace, { "Name" = "${var.project_name}-public" })
}

resource "aws_route_table_association" "aws_route_table_association_public" {
  for_each       = var.public_cidr
  subnet_id      = aws_subnet.aws_subnet_public[each.key].id
  route_table_id = aws_route_table.aws_route_table_public.id
}

# Route Table For Private Subnets

resource "aws_route_table" "aws_route_table_private" {
  vpc_id = aws_vpc.aws_vpc.id

  # route {
  #   cidr_block = "0.0.0.0/0"
  #   gateway_id = aws_internet_gateway.aws_internet_gateway.id
  # }

  tags = merge(local.common_tags, local.workspace, { "Name" = "${var.project_name}-private" })
}

resource "aws_route_table_association" "aws_route_table_association_private" {
  for_each       = var.private_cidr
  subnet_id      = aws_subnet.aws_subnet_private[each.key].id
  route_table_id = aws_route_table.aws_route_table_private.id
}

# VPC Endpoints

resource "aws_vpc_endpoint" "aws_vpc_endpoint_gateway" {
  for_each          = toset(var.gateway_endpoint_services)
  vpc_id            = aws_vpc.aws_vpc.id
  service_name      = "com.amazonaws.${data.aws_region.current.name}.${each.value}"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = [aws_route_table.aws_route_table_private.id]
  tags              = merge(local.common_tags, local.workspace, { "Name" = "${var.project_name}-${each.value}-gateway" })
}

resource "aws_vpc_endpoint" "aws_vpc_endpoint_interface" {
  for_each            = toset(var.gateway_endpoint_interface)
  vpc_id              = aws_vpc.aws_vpc.id
  service_name        = "com.amazonaws.${data.aws_region.current.name}.${each.value}"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  ip_address_type     = "ipv4"
  subnet_ids = [aws_subnet.aws_subnet_private["A"].id,
  aws_subnet.aws_subnet_private["B"].id]
  security_group_ids = [aws_security_group.aws_security_group_endpoint.id]
  tags               = merge(local.common_tags, local.workspace, { "Name" = "${var.project_name}-${each.value}-interface" })
}