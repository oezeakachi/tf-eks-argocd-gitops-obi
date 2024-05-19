# Define providers here if needed

# Declare the modules
module "networking" {
  source = "./modules/networking"
  # Pass any required variables to the networking module
  vpc_cidr             = var.vpc_cidr
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  availability_zones   = var.availability_zones
}

module "roles" {
  source = "./modules/roles"
  # Pass any required variables to the networking module

}

module "eks" {
  source = "./modules/eks"
  # Pass any required variables to the networking module
  cluster_name                = var.cluster_name
  desired_nodes               = var.desired_nodes
  max_nodes                   = var.max_nodes
  min_nodes                   = var.min_nodes
  aws_account_id              = var.aws_account_id
  iam_user                    = var.iam_user
  vpc_id                      = module.networking.vpc_id
  subnet_ids                  = module.networking.subnet_ids
  role_arn                    = module.roles.eks_cluster_role_arn
  eks_node_role               = module.roles.eks_node_role
  eks_node_role_arn           = module.roles.eks_node_role_arn
  eks_cluster_role_arn        = module.roles.eks_cluster_role_arn
  eks_cluster_policy          = module.roles.eks_cluster_policy
  eks_vpc_resource_controller = module.roles.eks_vpc_resource_controller
  rta                         = module.networking.rta[*]
  depends_on = [module.roles,
    module.networking
  ]
}
