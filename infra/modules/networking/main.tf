
# Create a VPC
resource "aws_vpc" "eks_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "eks-vpc"
  }
}

# Create Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.eks_vpc.id
  tags = {
    Name = "eks-igw"
  }
}

# Create Public Subnets
resource "aws_subnet" "public" {
  for_each = { for idx, cidr in var.public_subnet_cidrs : idx => cidr }
  vpc_id                  = aws_vpc.eks_vpc.id
  cidr_block              = each.value
  availability_zone       = element(var.availability_zones, each.key)
  map_public_ip_on_launch = true
  tags = {
    Name = "eks-public-subnet-${each.key}"
  }
}

# Create Private Subnets
resource "aws_subnet" "private" {
  for_each = { for idx, cidr in var.private_subnet_cidrs : idx => cidr }
  vpc_id                  = aws_vpc.eks_vpc.id
  cidr_block              = each.value
  availability_zone       = element(var.availability_zones, each.key)
  map_public_ip_on_launch = false
  tags = {
    Name = "eks-private-subnet-${each.key}"
  }
}

# Create Elastic IPs for NAT Gateways
resource "aws_eip" "nat_eip" {
  for_each = aws_subnet.public
  tags = {
    Name = "nat-eip-${each.key}"
  }
}

# Create NAT Gateways
resource "aws_nat_gateway" "nat_gw" {
  for_each      = aws_subnet.public
  allocation_id = aws_eip.nat_eip[each.key].id
  subnet_id     = each.value.id
  tags = {
    Name = "nat-gw-${each.key}"
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
    Name = "eks-public-routetable"
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
  for_each = aws_subnet.private
  vpc_id = aws_vpc.eks_vpc.id
  tags = {
    Name = "eks-private-routetable-${each.key}"
  }
}

# Create Routes for Private Subnet Route Table
resource "aws_route" "private" {
  for_each = aws_subnet.private
  route_table_id = aws_route_table.private[each.key].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id = aws_nat_gateway.nat_gw[tonumber(each.key) % length(aws_nat_gateway.nat_gw)].id
}

# Associate Route Table with Private Subnets
resource "aws_route_table_association" "private_rta" {
  for_each = aws_subnet.private
  subnet_id = each.value.id
  route_table_id = aws_route_table.private[each.key].id
}
