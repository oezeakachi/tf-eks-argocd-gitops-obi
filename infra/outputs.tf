output "eks_cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "eks_cluster_name" {
  value = module.eks.cluster_name
}

output "cluster_certificate_authority" {
  value = module.eks.cluster_certificate_authority
}

output "cluster_auth_token" {
  value = module.eks.cluster_auth_token
}
