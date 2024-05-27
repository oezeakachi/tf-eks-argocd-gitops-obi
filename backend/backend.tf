terraform {
  backend "s3" {
    bucket = "remote-rayen-tfstate"
    key    = "infra/terraform.tfstate"
    region = "eu-west-1"
  }
}
