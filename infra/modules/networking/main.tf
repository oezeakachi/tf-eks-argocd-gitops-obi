# Create a VPC
resource "aws_vpc" "eks_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "eks_vpc"
  }
}

# Create Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.eks_vpc.id
  tags = {
    Name = "eks_igw"
  }
}
# Create Elastic IPs for NAT Gateways
resource "aws_eip" "nat_eip" {
  count = length(var.public_subnet_cidrs)
  tags = {
    Name = "nat_eip_${count.index}"
  }
}

# Create NAT Gateways
resource "aws_nat_gateway" "nat_gw" {
  count         = length(var.public_subnet_cidrs)
  allocation_id = aws_eip.nat_eip[count.index].id
  subnet_id     = element(aws_subnet.public[count.index].id, count.index)
  tags = {
    Name = "nat_gw_${count.index}"
  }
}

# Create Public Subnets
resource "aws_subnet" "public" {
  count                   = length(var.public_subnet_cidrs)
  vpc_id                  = aws_vpc.eks_vpc.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = element(var.availability_zones, count.index)
  map_public_ip_on_launch = true
  tags = {
    Name = "eks_public_subnet_${count.index}"
  }
}
# Create Private Subnets
resource "aws_subnet" "private" {
  count                   = length(var.private_subnet_cidrs)
  vpc_id                  = aws_vpc.eks_vpc.id
  cidr_block              = var.private_subnet_cidrs[count.index]
  availability_zone       = element(var.availability_zones, count.index)
  map_public_ip_on_launch = false
  tags = {
    Name = "eks_private_subnet_${count.index}"
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
  count          = length(aws_subnet.public)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# Create Route Table for Private Subnets
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.eks_vpc.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = element(aws_nat_gateway.nat_gw[*].id, count.index % length(aws_nat_gateway.nat_gw))
  }
  tags = {
    Name = "eks_private_routetable"
  }
}

# Associate Route Table with Private Subnets
resource "aws_route_table_association" "private_rta" {
  count          = length(aws_subnet.private)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}