output "s3_bucket_arn" {
    value = aws_s3_bucket.tf_state.arn
    description = "The ARN of bigzero tf s3"
}

output "dynamodb_table" {
    value = aws_dynamodb_table.tf_locks.name
    description = "The name of the bigzero DynamoDB table"
}
