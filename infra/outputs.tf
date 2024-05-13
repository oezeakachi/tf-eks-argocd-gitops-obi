output "cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "cluster_certificate_authority" {
  value = module.eks.cluster_certificate_authority
}

output "cluster_auth_token" {
  value = module.eks.cluster_auth_token
}

output "cluster_name" {
  value =  module.eks.cluster_name
}


