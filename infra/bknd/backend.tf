resource "aws_s3_bucket" "tf_state" {
  bucket = "dp-terraform-state"
}

resource "aws_dynamodb_table" "locks" {
  name         = "dp-tf-locks"
  hash_key     = "LockID"
  billing_mode = "PAY_PER_REQUEST"

  attribute {
    name = "LockID"
    type = "S"
  }
}