provider "aws" {
    #region = "us-east-2"
    region = "ap-northeast-2"
}

resource "aws_s3_bucket" "tf_state" {
    bucket = "dy-tf-state"

    # 실로 S3 버킷 삭제방지
    lifecycle {
        prevent_destroy = true
    }

    # version 관리 
    /* deprecated
    versioning {
      enabled = true
    }
    */

    # 서버 측 암호화 활성화
    /* deprecated
    server_side_encryption_configuration {
        rule {
            apply_server_side_encryption_by_default {
              sse_algorithm = "AES256"
            }
        }
    }
    */
}

resource "aws_s3_bucket_versioning" "versioning_example" {
  bucket = aws_s3_bucket.tf_state.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "example" {
  bucket = aws_s3_bucket.tf_state.id

  rule {
    apply_server_side_encryption_by_default {
    #   kms_master_key_id = aws_kms_key.mykey.arn
      sse_algorithm     = "AES256"
    }
  }
}

resource "aws_dynamodb_table" "tf_locks" {
    name = "dy-tf-locks"
    billing_mode = "PAY_PER_REQUEST"
    hash_key = "LockID"

    attribute {
      name = "LockID"
      type = "S"
    }
}

# terraform 백엔드 구성
terraform {
  backend "s3" {
    bucket = "dy-tf-state"
    key = "global/s3/terraform.tfstate"
    region = "ap-northeast-2"

    dynamodb_table = "dy-tf-locks"
    encrypt = true
  }
}

output "s3_bucket_arn" {
    value = aws_s3_bucket.tf_state.arn
    description = "The ARN of bigzero tf s3"
}

output "dynamodb_table" {
    value = aws_dynamodb_table.tf_locks.name
    description = "The name of the bigzero DynamoDB table"
}
