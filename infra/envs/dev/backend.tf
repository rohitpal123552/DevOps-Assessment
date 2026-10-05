# Remote state for dev. The bucket must exist before `terraform init`.
# For a local review without AWS use: terraform init -backend=false
terraform {
  backend "s3" {
    bucket       = "hotel-terraform-state-dev"
    key          = "dev/terraform.tfstate"
    region       = "ap-south-1"
    encrypt      = true
    use_lockfile = true
  }
}
