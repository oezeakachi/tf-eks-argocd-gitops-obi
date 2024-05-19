output "vpc_id" {
  value = aws_vpc.eks_vpc.id
}

output "subnet_ids" {
  value = aws_subnet.private[*].id
}
output "private_rta" {
  value = aws_route_table_association.private_rta[*].id
}
