# Terraform state file to remote (S3 Bucket)
terraform {
  backend "s3" {
    bucket = "ultralinkk-terraform-state"
    key    = "02-workloads/03-database/terraform.tfstate"
    region = "eu-central-1"
    # skip_region_validation = true
    dynamodb_table = "ultralinkk-terraform-lock"
  }
}