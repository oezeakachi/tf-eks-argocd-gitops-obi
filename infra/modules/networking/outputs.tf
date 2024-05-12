output "vpc_id" {
  value = aws_vpc.eks_vpc.id
}

output "subnet_ids" {
  value = aws_subnet.subnet[*].id
}
output "rta" {
  value = aws_route_table_association.rta.id
}
