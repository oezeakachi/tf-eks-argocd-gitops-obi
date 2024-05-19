output "vpc_id" {
  value = aws_vpc.eks_vpc.id
}

output "subnet_ids" {
  value = [for subnet in aws_subnet.private : subnet.id]
}

output "private_rta" {
  value = [for rta in aws_route_table_association.private_rta : rta.id]
}
