# Create a kubeconfig file locally for operations
resource "local_file" "kubeconfig" {
  content         = var.kubeconfig
  filename        = local.kubeconf_path
  file_permission = "0600"
}

# Set the kubeconfig path for the Operations cluster.
provider "kubernetes" {

  host = "${yamldecode(var.kubeconfig).clusters[0].cluster.server}"
  cluster_ca_certificate = "${base64decode(yamldecode(var.kubeconfig).clusters[0].cluster.certificate-authority-data)}"
  token = "${yamldecode(var.kubeconfig).users[0].user.token}"
}

# Create a new namespace for ArgoCD.
resource "kubernetes_namespace" "ArgoCD" {
  metadata {
    name = var.namespace
  }
}

# Install the ArgoCD install file.
resource "null_resource" "ArgoCD" {

  # download kubectl
  provisioner "local-exec" {
    command = "curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl && chmod +x kubectl"
  }

  # download ArgoCD YAML file locally
  provisioner "local-exec" {
    command = "wget ${local.install_script} -O ./install.yaml"
  }

  # Install the ArgoCD YAML file.
  provisioner "local-exec" {
    command = "./kubectl apply -n ${kubernetes_namespace.ArgoCD.metadata[0].name} -f ./install.yaml"

    environment = {
      KUBECONFIG = "${local.kubeconf_path}"
    }
  }

  # Create a load balancer for external access
  provisioner "local-exec" {
    command = "./kubectl patch svc argocd-server -n ${kubernetes_namespace.ArgoCD.metadata[0].name} -p '{\"spec\": {\"type\": \"LoadBalancer\"}}'"

    environment = {
      KUBECONFIG = "${local.kubeconf_path}"
    }
  }

  # Cleanup the downloaded file
  provisioner "local-exec" {
    command = "rm ./install.yaml"
  }
}

