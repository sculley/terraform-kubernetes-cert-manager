# Create cert-manager namespace
resource "kubernetes_namespace" "cert_manager_namespace" {
  metadata {
    name = var.namespace
  }
}

# Install cert-manager helm chart
resource "helm_release" "cert_manager" {
  name             = var.helm_release_name
  repository       = var.helm_repository_url
  chart            = var.helm_chart_name

  namespace        = var.namespace

  set {
    name  = "installCRDs"
    value = "true"
  }

  values = [
    templatefile("${path.module}/values.yaml.tpl", {
      replica_count = var.replica_count
    })
  ]

  depends_on = [ 
    kubernetes_namespace.cert_manager_namespace
   ]
}