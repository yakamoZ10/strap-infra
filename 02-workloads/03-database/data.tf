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

data "terraform_remote_state" "strapi" {
  backend = "s3"

  config = {
    bucket = "ultralinkk-terraform-state"
    key    = "02-workloads/04-strapi/terraform.tfstate"
    region = "eu-central-1"
    # skip_region_validation = true
    dynamodb_table = "ultralinkk-terraform-lock"
  }
}




data "aws_secretsmanager_secret" "db_secret" {
  name = "dev/ultralinkk/strapi" # Replace with your secret's name
}

# Retrieve the version of the secret
data "aws_secretsmanager_secret_version" "db_secret_version" {
  secret_id = data.aws_secretsmanager_secret.db_secret.id
}
