# Remote state for prod, kept in its own bucket and key.
# For a local review without AWS use: terraform init -backend=false
terraform {
  backend "s3" {
    bucket       = "hotel-terraform-state-prod"
    key          = "prod/terraform.tfstate"
    region       = "ap-south-1"
    encrypt      = true
    use_lockfile = true
  }
}
