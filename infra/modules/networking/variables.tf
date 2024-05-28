# CIDR block for the VPC
variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}
# CIDR blocks for the public subnets
variable "public_subnet_cidrs" {
  description = "List of CIDR blocks for the public subnets"
  type        = list(string)
}

# CIDR blocks for the private subnets
variable "private_subnet_cidrs" {
  description = "List of CIDR blocks for the private subnets"
  type        = list(string)
}

# Availability zones for the subnets
variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
}
