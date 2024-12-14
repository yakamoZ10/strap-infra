output "bucket_rn" {
  value = aws_s3_bucket.tf_state.arn
}

output "dynamodb_table_arn" {
  value = aws_dynamodb_table.tf_lock_table.arn
}
