locals {
  project = "ultralinkk"

  name = "${local.project}-${var.environment}"

  vpc_cidr_block = "10.0.0.0/16"

  default_tags = {
    Project     = local.project
    Environment = var.environment
    Training    = "devops-engineer-associate"
  }
}

resource "aws_vpc" "main" {
  cidr_block = local.vpc_cidr_block

  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge({ Name = local.name }, local.default_tags)
}

# Public Subnets
resource "aws_subnet" "public" {
  count                   = 2
  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(aws_vpc.main.cidr_block, 10, count.index) # Creates two public subnets
  availability_zone       = element(data.aws_availability_zones.available.names, count.index)
  map_public_ip_on_launch = true


  tags = merge({
    Name = "public-subnet-${count.index + 1}",
    Tier = "Public"
  }, local.default_tags)
}

# Strapi Server Subnets (Private)
resource "aws_subnet" "strapi_server" {
  count             = 2
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(aws_vpc.main.cidr_block, 8, count.index + 2) # Creates two private subnets
  availability_zone = element(data.aws_availability_zones.available.names, count.index)

  tags = merge({
    Name = "strapi-server-subnet-${count.index + 1}",
    Tier = "Private"
  }, local.default_tags)
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = merge({ Name = local.name }, local.default_tags)
}


# Elastic IP for NAT Gateway
resource "aws_eip" "nat_gtw_eip" {
  domain = "vpc"

  tags = merge({ Name = local.name }, local.default_tags)
}

# NAT Gateway for Private Subnets
resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat_gtw_eip.id
  subnet_id     = aws_subnet.public[0].id # NAT Gateway in first public subnet

  tags = merge({ Name = local.name }, local.default_tags)
}

# Public Route Table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = merge({ Name = "rtb-public" }, local.default_tags)
}

# Associate Public Subnets with Public Route Table
resource "aws_route_table_association" "public_association" {
  count          = length(aws_subnet.public)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# Strapi Servers Route Table
resource "aws_route_table" "strapi_server" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main.id
  }

  tags = merge({ Name = "rtb-strapi-server" }, local.default_tags)
}

#Associate Strapi Server Subnets with Strapi Server Route Table
resource "aws_route_table_association" "strapi_association" {
  count          = length(aws_subnet.strapi_server)
  subnet_id      = aws_subnet.strapi_server[count.index].id
  route_table_id = aws_route_table.strapi_server.id
}


# DB Server Subnets (Private)
resource "aws_subnet" "db_server" {
  count             = 2
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(aws_vpc.main.cidr_block, 8, count.index + 20) # Creates two private subnets
  availability_zone = element(data.aws_availability_zones.available.names, count.index)

  tags = merge({
    Name = "db-server-subnet-${count.index + 1}",
    Tier = "Private"
  }, local.default_tags)
}

# DB Servers Route Table
resource "aws_route_table" "db_server" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main.id
  }

  tags = merge({ Name = "rtb-db-server" }, local.default_tags)
}

# Associate DB Server Subnets with DB Server Route Table
resource "aws_route_table_association" "db_server_association" {
  count          = length(aws_subnet.db_server)
  subnet_id      = aws_subnet.db_server[count.index].id
  route_table_id = aws_route_table.db_server.id
}