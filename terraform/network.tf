####################
# VPC and Subnet Setup
####################

# Create VPC with DNS support (needed for RDS hostname resolution)
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags                 = { Name = "lambda-vpc" }
}

# Get available AZs in the region (we'll use the first two for subnets)
data "aws_availability_zones" "available" {
  state = "available"
}

# Public subnets (for ALB, NAT, and optionally RDS if public)
resource "aws_subnet" "public" {
  count                   = length(var.public_subnet_cidrs)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true # instances in public subnets get public IP by default
  tags                    = { Name = "public-subnet-${count.index}" }
}

# Private subnets (for Lambda and RDS)
resource "aws_subnet" "private" {
  count             = length(var.private_subnet_cidrs)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_cidrs[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]
  # No public IPs in private subnets
  tags = { Name = "private-subnet-${count.index}" }
}

# Internet Gateway for the VPC (allows outbound to internet from public subnet)
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags   = { Name = "vpc-igw" }
}

# Route table for public subnets: route 0.0.0.0/0 to Internet Gateway
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  tags   = { Name = "public-rt" }

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

# Associate public subnets with the public route table
resource "aws_route_table_association" "public_assoc" {
  count          = length(var.public_subnet_cidrs)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# NAT Gateway (for private subnets' internet access, if enabled)
# Requires an Elastic IP for the NAT
resource "aws_eip" "nat_eip" {
  count  = var.allow_lambda_internet_access ? 1 : 0
  domain = "vpc"
}
resource "aws_nat_gateway" "nat" {
  count         = var.allow_lambda_internet_access ? 1 : 0
  allocation_id = aws_eip.nat_eip[0].id
  subnet_id     = aws_subnet.public[0].id # put NAT in the first public subnet
  tags          = { Name = "nat-gateway" }
}

# Route table for private subnets: route 0.0.0.0/0 to NAT Gateway (if exists)
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id
  tags   = { Name = "private-rt" }

  # Only add default route if NAT Gateway is created
  provisioner "local-exec" {
    when    = create
    command = "echo 'Private RT created'"
  }
}

# Conditional route for private subnets if internet access is allowed
resource "aws_route" "private_nat_route" {
  count                  = var.allow_lambda_internet_access ? 1 : 0
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat[0].id
}

# Associate private subnets with the private route table
resource "aws_route_table_association" "private_assoc" {
  count          = length(var.private_subnet_cidrs)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}
