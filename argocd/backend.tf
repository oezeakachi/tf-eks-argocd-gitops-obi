terraform {
  backend "s3" {
    bucket = "remote-tfstate-obi"
    key    = "argocd/terraform.tfstate"
    region = "eu-west-1"
  }
}
