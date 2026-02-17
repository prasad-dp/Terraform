include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "../../../modules/vpc"
}

inputs = {
  cidr           = "172.16.0.0/16"
  public_subnets = ["172.16.1.0/24"]
}