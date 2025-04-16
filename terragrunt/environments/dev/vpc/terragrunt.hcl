terraform {
  source = find_in_parent_folders("modules/vpc")
}

include {
  path = find_in_parent_folders()
  expose = true
}


inputs = {
  environment = include.locals.env.locals.environment
  vpc_name    = include.locals.env.locals.vpc_name
  vpc_cidr    = include.locals.env.locals.vpc_cidr
  azs         = include.locals.env.locals.azs
  cluster_name    = include.locals.env.locals.cluster_name
  enable_nat_gateway = true
  single_nat_gateway = true
  enable_dns_hostnames = true
} 