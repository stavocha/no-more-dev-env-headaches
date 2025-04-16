terraform {
  source = "../../../modules//addons"
}

include {
  path = find_in_parent_folders()
}

dependency "eks" {
  config_path = "../eks"
}

inputs = {
  environment = local.environment
  aws_region  = local.aws_region
} 