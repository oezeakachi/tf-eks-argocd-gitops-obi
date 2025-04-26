terraform {
  backend "s3" {
    bucket = "remote-tfstate-obi"
    key    = "infra/terraform.tfstate"
    region = "eu-west-1"
  }
}
