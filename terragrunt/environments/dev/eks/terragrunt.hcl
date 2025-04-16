terraform {
  source = "../../../modules//eks"
}

include {
  path = find_in_parent_folders()
}

dependency "vpc" {
  config_path = "../vpc"
}

inputs = {
  environment = local.env.locals.environment
  aws_region  = local.env.locals.aws_region
  vpc_id      = dependency.vpc.outputs.vpc_id
  private_subnets = dependency.vpc.outputs.private_subnets
  public_subnets = dependency.vpc.outputs.public_subnets
  
  cluster_name    = local.env.locals.cluster_name
  cluster_version = local.env.locals.cluster_version
  
  node_group_name      = local.env.locals.node_group_name
  node_instance_types  = local.env.locals.node_instance_types
  node_min_size        = local.env.locals.node_min_size
  node_max_size        = local.env.locals.node_max_size
  node_desired_size    = local.env.locals.node_desired_size
  node_disk_size       = local.env.locals.node_disk_size

} 