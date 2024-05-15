output "eks_cluster_endpoint" {
  value     = module.eks.cluster_endpoint
  sensitive = true
}

output "eks_cluster_name" {
  value     = module.eks.cluster_name
  sensitive = true
}

output "cluster_certificate_authority" {
  value     = module.eks.cluster_certificate_authority
  sensitive = true
}

output "cluster_auth_token" {
  value     = module.eks.cluster_auth_token
  sensitive = true
}
