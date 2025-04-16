# ArgoCD Configuration
variable "enable_argocd" {
  description = "Enable ArgoCD add-on"
  type        = bool
  default     = true
}

# NGINX Ingress Configuration
variable "enable_ingress_nginx" {
  description = "Enable NGINX Ingress Controller add-on"
  type        = bool
  default     = true
}

# External DNS Configuration
variable "enable_external_dns" {
  description = "Enable External DNS add-on"
  type        = bool
  default     = true
}

# External Secrets Configuration
variable "enable_external_secrets" {
  description = "Enable External Secrets add-on"
  type        = bool
  default     = true
}


# Cert Manager Configuration
variable "enable_cert_manager" {
  description = "Enable Cert Manager add-on"
  type        = bool
  default     = true
}