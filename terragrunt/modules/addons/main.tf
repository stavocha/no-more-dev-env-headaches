# Add EKS Blueprints Add-ons
module "eks_blueprints_kubernetes_addons" {
  source = "github.com/aws-ia/terraform-aws-eks-blueprints//modules/kubernetes-addons?ref=v4.32.1"
  
  # Enable ArgoCD
  enable_argocd = var.enable_argocd
  argocd_helm_config = var.enable_argocd ? {
    version = var.argocd_helm_chart_version
    values = [
      <<-EOT
      server:
        service:
          type: ClusterIP
        extraArgs:
          - --insecure
      controller:
        metrics:
          enabled: true
      server:
        metrics:
          enabled: true
      EOT
    ]
  } : null

  # Enable NGINX Ingress Controller
  enable_ingress_nginx = var.enable_ingress_nginx
  ingress_nginx_helm_config = var.enable_ingress_nginx ? {
    version = var.nginx_ingress_helm_chart_version
    values = [
      <<-EOT
      controller:
        service:
          type: LoadBalancer
        metrics:
          enabled: true
        autoscaling:
          enabled: true
          minReplicas: 2
          maxReplicas: 5
      EOT
    ]
  } : null

  # Enable External DNS
  enable_external_dns = var.enable_external_dns
  external_dns_helm_config = var.enable_external_dns ? {
    version = var.external_dns_helm_chart_version
    values = [
      <<-EOT
      provider: aws
      policy: sync
      metrics:
        enabled: true
      EOT
    ]
  } : null

  # Enable External Secrets
  enable_external_secrets = var.enable_external_secrets
  external_secrets_helm_config = var.enable_external_secrets ? {
    version = var.external_secrets_helm_chart_version
    values = [
      <<-EOT
      serviceAccount:
        create: true
      metrics:
        enabled: true
      EOT
    ]
  } : null

  # Enable Cert Manager
  enable_cert_manager = var.enable_cert_manager
  cert_manager_helm_config = var.enable_cert_manager ? {
    version = var.cert_manager_helm_chart_version
    values = [
      <<-EOT
      installCRDs: true
      serviceAccount:
        create: true
      metrics:
        enabled: true
      EOT
    ]
  } : null
}