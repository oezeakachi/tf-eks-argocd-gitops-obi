output "cluster_endpoint" {
  value = data.aws_eks_cluster.cluster.endpoint
}

output "cluster_certificate_authority" {
  value = data.aws_eks_cluster.cluster.certificate_authority[0].data
}

output "cluster_auth_token" {
  value = data.aws_eks_cluster_auth.cluster.token
}

output "cluster_name" {
  value =  data.aws_eks_cluster.cluster.name
}
