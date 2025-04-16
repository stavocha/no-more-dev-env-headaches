locals {
  environment = "dev"
  aws_region  = "us-east-1"
  
  # VPC Configuration
  vpc_name    = "dev-vpc"
  vpc_cidr    = "10.0.0.0/16"
  azs         = ["us-east-1a", "us-east-1b", "us-east-1c"]
  
  # EKS Configuration
  cluster_name    = "dev-eks-cluster"
  cluster_version = "1.31"
  
  # Node Group Configuration
  node_group_name      = "dev-node-group"
  node_instance_types  = ["t2.micro"]
  node_min_size        = 1
  node_max_size        = 1
  node_desired_size    = 1
  node_disk_size       = 10
  
} 

