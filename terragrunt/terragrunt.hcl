# remote_state {
#   backend = "s3"
#   config = {
#     bucket         = "your-terraform-state-bucket"
#     key            = "${path_relative_to_include()}/terraform.tfstate"
#     region         = "us-east-1"
#     encrypt        = true
#     dynamodb_table = "terraform-locks"
#   }
#   generate = {
#     path      = "backend.tf"
#     if_exists = "overwrite"
#   }
# }

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite"
  contents  = <<EOF
provider "aws" {
  region = var.aws_region
  default_tags {
    tags = {
      Environment = var.environment
      ManagedBy   = "terraform"
    }
  }
}
EOF
}
