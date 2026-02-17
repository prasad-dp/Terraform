
remote_state {
  backend = "s3"
  config = {
    bucket         = "dp-terraform-state"
    key            = "${path_relative_to_include()}/terraform.tfstate"
    region         = "ap-south-1"
    dynamodb_table = "dp-tf-locks"
    encrypt        = true
  }
}
