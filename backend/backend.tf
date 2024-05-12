terraform {
  backend "s3" {
    bucket = "remote-rayen-tfstate"
    key    = "eks/terraform.tfstate"
    region = "eu-west-1"
   }
}
