terraform {
  backend "s3" {
    bucket       = "aldo-devops-kubernetes-terraform-state"
    key          = "eks/dev/terraform.tfstate"
    region       = "ap-southeast-1"
    encrypt      = true
    use_lockfile = true
  }
}