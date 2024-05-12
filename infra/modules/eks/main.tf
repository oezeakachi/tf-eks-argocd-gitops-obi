# Networking module

module "networking" {
  source = "../networking"
  # Pass any required variables to the networking module
  vpc_cidr = var.vpc_cidr
  subnet_cidrs = var.subnet_cidrs
  availability_zones = var.availability_zones
}

module "roles" {
  source = "../roles"
  # Pass any required variables to the networking module

}


# Security group for the EKS cluster
resource "aws_security_group" "eks_cluster_sg" {
  name        = "eks_cluster_sg"
  description = "Security group for EKS cluster"
  vpc_id      = module.networking.vpc_id
}

# EKS Cluster
resource "aws_eks_cluster" "cluster" {
  name     = var.cluster_name
  role_arn = module.roles.eks_cluster_role_arn
  vpc_config {
    security_group_ids = [aws_security_group.eks_cluster_sg.id]
    subnet_ids         = module.networking.subnet_ids
  }
  depends_on = [
    module.roles.eks_cluster_policy,
    module.roles.eks_vpc_resource_controller,
    module.networking.rta
  ]
}

# ConfigMap aws-auth for EKS
resource "kubernetes_config_map" "aws_auth" {
  depends_on = [
    aws_eks_cluster.cluster,
    aws_iam_role.eks_node_role
  ]

  metadata {
    name      = "aws-auth"
    namespace = "kube-system"
  }

  data = {
    mapRoles = yamlencode([{
      rolearn  = aws_iam_role.eks_cluster_role.arn
      username = "system:node:{{EC2PrivateDNSName}}"
      groups   = ["system:bootstrappers", "system:nodes"]
      }, {
      rolearn  = aws_iam_role.eks_node_role.arn
      username = "system:node:{{EC2PrivateDNSName}}"
      groups   = ["system:bootstrappers", "system:nodes"]
      }, {
      rolearn  = aws_iam_role.eks_cluster_role.arn
      username = "my_eks_cluster_role"
      groups   = ["system:masters"]
    }])
  }
}
# EKS Node Group
resource "aws_eks_node_group" "node_group" {
  cluster_name    = aws_eks_cluster.cluster.name
  node_group_name = "my_eks_node_group"
  node_role_arn   = aws_iam_role.eks_node_role.arn
  subnet_ids      = aws_subnet.subnet[*].id

  scaling_config {
    desired_size = var.desired_nodes
    max_size     = var.max_nodes
    min_size     = var.min_nodes
  }

  instance_types = ["t3.medium"]

  depends_on = [
    aws_eks_cluster.cluster
  ]
}
