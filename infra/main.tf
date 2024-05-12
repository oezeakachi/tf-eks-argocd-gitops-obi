# Define providers here if needed

# Declare the modules
module "networking" {
  source = "./modules/networking"
  # Pass any required variables to the networking module
  vpc_cidr          = var.vpc_cidr
  subnet_cidrs      = var.subnet_cidrs
  availability_zones = var.availability_zones
}

