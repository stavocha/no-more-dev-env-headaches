# Get current AWS account ID
data "aws_caller_identity" "current" {}

module "eks" {
  source = "github.com/terraform-aws-modules/terraform-aws-eks?ref=v20.24.2"

  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version

  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = true

  vpc_id     = var.vpc_id
  subnet_ids = var.private_subnets

  cluster_enabled_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]

  eks_managed_node_groups = {
    default = {
      name           = var.node_group_name
      instance_types = var.node_instance_types
      capacity_type  = "SPOT"
      min_size     = var.node_min_size
      max_size     = var.node_max_size
      desired_size = var.node_desired_size
      disk_size = var.node_disk_size
      subnet_ids = [var.private_subnets[0]]
    }
  }

  # Configure cluster access entry
  access_entries = {
    admin = {
      principal_arn    = "arn:aws:iam::303051479108:user/no-more-dev-env-headaches"
      policy_associations = {
        admin = {
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
          access_scope = {
            type = "cluster"
          }
        }
      }
    }
  }

  tags = {
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}