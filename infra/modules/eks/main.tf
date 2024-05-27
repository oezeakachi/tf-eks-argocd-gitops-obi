# Security group for the EKS cluster
resource "aws_security_group" "eks_cluster_sg" {
  name        = "eks-cluster-sg"
  description = "Security group for EKS cluster"
  vpc_id      = var.vpc_id
}

# EKS Cluster
resource "aws_eks_cluster" "cluster" {
  name     = var.cluster_name
  role_arn = var.role_arn
  vpc_config {
    security_group_ids = [aws_security_group.eks_cluster_sg.id]
    subnet_ids         = var.private_subnet_ids
  }
  depends_on = [
    var.eks_cluster_policy,
    var.eks_vpc_resource_controller,
    var.rta
  ]
}
data "aws_eks_cluster" "cluster" {
  name = aws_eks_cluster.cluster.name
}

data "aws_eks_cluster_auth" "cluster" {
  name = aws_eks_cluster.cluster.name
}


# ConfigMap aws-auth for EKS
resource "kubernetes_config_map" "aws_auth" {
  depends_on = [
    aws_eks_cluster.cluster,
    var.eks_node_role
  ]

  metadata {
    name      = "aws-auth"
    namespace = "kube-system"
  }

  data = {
    mapRoles = yamlencode([{
      rolearn  = var.eks_cluster_role_arn
      username = "system:node:{{EC2PrivateDNSName}}"
      groups   = ["system:bootstrappers", "system:nodes"]
      }, {
      rolearn  = var.eks_node_role_arn
      username = "system:node:{{EC2PrivateDNSName}}"
      groups   = ["system:bootstrappers", "system:nodes"]
      }, {
      rolearn  = var.eks_cluster_role_arn
      username = "eks_cluster_role"
      groups   = ["system:masters"]
    }])
    mapUsers = yamlencode([
      {
        userarn  = "arn:aws:iam::${var.aws_account_id}:${var.iam_user}"
        username = var.iam_user
        groups   = ["system:masters"]
      }
    ])
  }
}

# EKS Node Group
resource "aws_eks_node_group" "node_group" {
  cluster_name    = aws_eks_cluster.cluster.name
  node_group_name = "eks-node-group"
  node_role_arn   = var.eks_node_role_arn
  subnet_ids      = var.private_subnet_ids
  scaling_config {
    desired_size = var.desired_nodes
    max_size     = var.max_nodes
    min_size     = var.min_nodes
  }

  instance_types = ["t3.small"]

  depends_on = [
    aws_eks_cluster.cluster
  ]
}

