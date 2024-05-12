# Define providers here if needed

# Declare the modules
module "networking" {
  source = "./modules/networking"
  # Pass any required variables to the networking module
  vpc_cidr           = var.vpc_cidr
  subnet_cidrs       = var.subnet_cidrs
  availability_zones = var.availability_zones
}

module "roles" {
  source = "./modules/roles"
  # Pass any required variables to the networking module

}

module "eks" {
  source = "./modules/eks"
  # Pass any required variables to the networking module
  vpc_id = var.vpc_id
  cluster_name  = var.cluster_name
  desired_nodes = var.desired_nodes
  max_nodes     = var.max_nodes
  min_nodes     = var.min_nodes
  depends_on = [module.roles,
    module.networking
  ]
}
