provider "aws" {
  region = var.aws_region
}

provider "aws" {
  alias  = "iam_global"
  region = "us-east-1"

  endpoints {
    iam = "https://iam.global.api.aws"
  }

  skip_credentials_validation = true
  skip_requesting_account_id  = true
  skip_metadata_api_check     = true

}