terraform {
  backend "s3" {
    bucket = "remote-rayen-tfstate-obi"
    key    = "argocd/terraform.tfstate"
    region = "eu-west-1"
  }
}
