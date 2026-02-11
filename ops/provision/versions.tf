terraform {
  backend "s3" {
    bucket  = "terraform-state-ams2"
    key     = "ams/terraform.tfstate"
    region  = "us-west-2"
    profile = "gbh"
  }
  required_version = "> 0.13"
}
