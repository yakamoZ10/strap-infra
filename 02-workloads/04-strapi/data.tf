data "terraform_remote_state" "networking" {
  backend = "s3"

  config = {
    bucket = "ultralinkk-terraform-state"
    key    = "02-workloads/02-networking/terraform.tfstate"
    region = "eu-central-1"
    # skip_region_validation = true
    dynamodb_table = "ultralinkk-terraform-lock"
  }
}

data "terraform_remote_state" "db" {
  backend = "s3"

  config = {
    bucket = "ultralinkk-terraform-state"
    key    = "02-workloads/03-database/terraform.tfstate"
    region = "eu-central-1"
    # skip_region_validation = true
    dynamodb_table = "ultralinkk-terraform-lock"
  }
}



data "aws_route53_zone" "superlink" {
  name         = "superlink.one"
  private_zone = false
}