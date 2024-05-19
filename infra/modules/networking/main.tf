# Create a VPC
resource "aws_vpc" "eks_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "eks_vpc"
  }
}

# Create Elastic IPs for NAT Gateways
resource "aws_eip" "nat_eip" {
  for_each = aws_subnet.public
  tags = {
    Name = "nat_eip_${each.key}"
  }
}
# Create NAT Gateways
resource "aws_nat_gateway" "nat_gw" {
  for_each      = aws_subnet.public
  allocation_id = aws_eip.nat_eip[each.key].id
  subnet_id     = each.value.id
  tags = {
    Name = "nat_gw_${each.key}"
  }
}

# Create Public Subnets
resource "aws_subnet" "public" {
  for_each = toset(var.public_subnet_cidrs)
  vpc_id                  = aws_vpc.eks_vpc.id
  cidr_block              = each.value
  availability_zone       = element(var.availability_zones, index(var.public_subnet_cidrs, each.value))
  map_public_ip_on_launch = true
  tags = {
    Name = "eks_public_subnet_${each.key}"
  }
}

# Create Private Subnets
resource "aws_subnet" "private" {
  for_each = toset(var.private_subnet_cidrs)
  vpc_id                  = aws_vpc.eks_vpc.id
  cidr_block              = each.value
  availability_zone       = element(var.availability_zones, index(var.private_subnet_cidrs, each.value))
  map_public_ip_on_launch = false
  tags = {
    Name = "eks_private_subnet_${each.key}"
  }
}
# Create Route Table for Public Subnets
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.eks_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = "eks_public_routetable"
  }
}

# Associate Route Table with Public Subnets
resource "aws_route_table_association" "public_rta" {
  for_each      = aws_subnet.public
  subnet_id     = each.value.id
  route_table_id = aws_route_table.public.id
}

# Create Route Table for Private Subnets
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.eks_vpc.id
  tags = {
    Name = "eks_private_routetable"
  }
}

# Create Routes for Private Subnet Route Table
resource "aws_route" "private" {
  for_each      = aws_subnet.private
  route_table_id = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id = element(aws_nat_gateway.nat_gw[*].id, each.key % length(aws_nat_gateway.nat_gw))
}

# Associate Route Table with Private Subnets
resource "aws_route_table_association" "private_rta" {
  for_each      = aws_subnet.private
  subnet_id     = each.value.id
  route_table_id = aws_route_table.private.id
}