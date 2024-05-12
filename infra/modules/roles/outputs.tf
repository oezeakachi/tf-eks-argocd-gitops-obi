output "eks_cluster_role_arn" {
  value = aws_iam_role.eks_cluster_role.arn
}

output "eks_cluster_policy" {
  value = aws_iam_role_policy_attachment.eks_cluster_policy
}

output "eks_vpc_resource_controller" {
  value = aws_iam_role_policy_attachment.eks_vpc_resource_controller
}