terraform {
  backend "s3" {
    bucket       = "togglemaster-terraform-state-1234567"
    key          = "dev/terraform.tfstate"
    region       = "us-east-1"
    use_lockfile = true
    encrypt      = true
  }
}
