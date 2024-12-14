locals {
  project = "ultralink"

  default_tags = {
    Project  = local.project
    Training = "devops-engineer-associate"
  }
}

# Create S3 bucket for storing Terraform state
resource "aws_s3_bucket" "tf_state" {
  bucket = "${local.project}-terraform-state"

  tags = local.default_tags
}

resource "aws_s3_bucket_ownership_controls" "tf_state" {
  bucket = aws_s3_bucket.tf_state.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "tf_state" {
  bucket = aws_s3_bucket.tf_state.id
  acl    = "private"

  depends_on = [aws_s3_bucket_ownership_controls.tf_state]
}

# DynamoDB table for state locking and consistency checks
resource "aws_dynamodb_table" "tf_lock_table" {
  name         = "${local.project}-terraform-lock"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = local.default_tags
}