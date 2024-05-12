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

# Create Subnets
resource "aws_subnet" "subnet" {
  count                   = length(var.subnet_cidrs)
  vpc_id                  = aws_vpc.eks_vpc.id
  cidr_block              = var.subnet_cidrs[count.index]
  availability_zone       = element(var.availability_zones, count.index)
  map_public_ip_on_launch = true
  tags = {
    Name = "eks_subnet_${count.index}"
  }
}

# Create Route Table
resource "aws_route_table" "routetable" {
  vpc_id = aws_vpc.eks_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = "eks_routetable"
  }
}

# Associate Route Table with Subnets
resource "aws_route_table_association" "rta" {
  count          = length(aws_subnet.subnet)
  subnet_id      = aws_subnet.subnet[count.index].id
  route_table_id = aws_route_table.routetable.id
}
