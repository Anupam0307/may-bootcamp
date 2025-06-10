# VPC 

# 10.0.0.0/16 
# 10.0.1.0/24 -> 32-24^^2 -2 

# rds  subnet
# 10.0.1.0/24 , 10.0.2.0/24
# prvate subnet 
# 10.0.3.0/24 , 10.0.4.0/24
# public subnet
# 10.0.5.0/24, 10.0.6.0/24

# vpc
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "${var.prefix}-${var.environment}-vpc"
  }
}

# 2 private subnets
resource "aws_subnet" "private_1" {
  # cidr_block        = "10.0.1.0/24"
  cidr_block        = var.subnet_cidr["private_1"]
  availability_zone = var.zone1
  vpc_id            = aws_vpc.main.id

  tags = {
    Name = "ECS Fargate Private Subnet 1"
  }
}

resource "aws_subnet" "private_2" {
  # cidr_block        = "10.0.2.0/24"
  cidr_block        = var.subnet_cidr["private_2"]
  availability_zone = var.zone2
  vpc_id            = aws_vpc.main.id

  tags = {
    Name = "ECS Fargate Private Subnet 2"
  }
}

# 2 public subnets

resource "aws_subnet" "public_1" {
  # cidr_block              = "10.0.3.0/24"
  cidr_block              = var.subnet_cidr["public_1"]
  availability_zone       = var.zone1
  vpc_id                  = aws_vpc.main.id
  map_public_ip_on_launch = true

  tags = {
    Name = "ECS Fargate Public Subnet 1"
  }
}

resource "aws_subnet" "public_2" {
  # cidr_block              = "10.0.4.0/24"
  cidr_block              = var.subnet_cidr["public_2"]
  availability_zone       = var.zone2
  vpc_id                  = aws_vpc.main.id
  map_public_ip_on_launch = true

  tags = {
    Name = "ECS Fargate Public Subnet 2"
  }
}
# 2 private subnet for database
resource "aws_subnet" "rds_1" {
  # cidr_block        = "10.0.5.0/24"
  cidr_block        = var.subnet_cidr["db_subnet_1"]
  availability_zone = data.aws_availability_zones.available_zones.names[0]
  vpc_id            = aws_vpc.main.id

  tags = {
    Name = "RDS Private Subnet 1"
  }
}

resource "aws_subnet" "rds_2" {
  # cidr_block        = "10.0.6.0/24"
  cidr_block        = var.subnet_cidr["db_subnet_2"]
  availability_zone = data.aws_availability_zones.available_zones.names[1]
  vpc_id            = aws_vpc.main.id

  tags = {
    Name = "RDS Private Subnet 2"
  }
}

# internet gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.environment}-igw"
  }
}

# 2 elasetic ip
# Elastic IPs for NAT Gateways
resource "aws_eip" "nat_1" {
  depends_on = [aws_internet_gateway.main]
  tags = {
    Name = "NAT Gateway EIP 1"
  }
}

resource "aws_eip" "nat_2" {
  depends_on = [aws_internet_gateway.main]
  tags = {
    Name = "NAT Gateway EIP 2"
  }
}

# route table for public subnet
resource "aws_route_table" "public_1" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "public Route Table 1"
  }
}

resource "aws_route_table" "public_2" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "public Route Table 2"
  }
}

# route for public subnet
resource "aws_route_table_association" "public_1" {
  subnet_id      = aws_subnet.public_1.id
  route_table_id = aws_route_table.public_1.id
}

resource "aws_route_table_association" "public_2" {
  subnet_id      = aws_subnet.public_2.id
  route_table_id = aws_route_table.public_2.id
}

# route table for private subnet
resource "aws_route_table" "private_1" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_1.id
  }

  tags = {
    Name = "Private Route Table 1"
  }
}

resource "aws_route_table" "private_2" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_2.id
  }

  tags = {
    Name = "Private Route Table 2"
  }
}

# route table association for private subnet
resource "aws_route_table_association" "private_1" {
  subnet_id      = aws_subnet.private_1.id
  route_table_id = aws_route_table.private_1.id
}

resource "aws_route_table_association" "private_2" {
  subnet_id      = aws_subnet.private_2.id
  route_table_id = aws_route_table.private_2.id
}

# nat gateway
# nat gateway 2 if them

resource "aws_nat_gateway" "nat_1" {
  subnet_id     = aws_subnet.public_1.id
  allocation_id = aws_eip.nat_1.id

  tags = {
    Name = "NAT Gateway 1"
  }
}

resource "aws_nat_gateway" "nat_2" {
  subnet_id     = aws_subnet.public_2.id
  allocation_id = aws_eip.nat_2.id

  tags = {
    Name = "NAT Gateway 2"
  }
}

# SG ##  rds <- 5432 -> ecs <- 8000 -> lb <- 80/443 -> internet