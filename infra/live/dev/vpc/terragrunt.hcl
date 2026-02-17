include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "../../../modules/vpc"
}

inputs = {
  cidr           = "10.0.0.0/16"
  public_subnets = ["10.0.1.0/24"]
}