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

# Template file is required for setting the trigger. This is to apply the new install scripts whenever there is change the install script.
# You can download the latest file from https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
# data "template_file" "argocd_install" {
#   template = "${file("${local.install_script}")}"
# }

# Install the ArgoCD install file.
resource "null_resource" "ArgoCD" {

  #Trigger when the yaml file changes
  # triggers = {
  #   yaml_sha_install  = "${sha256(file("${local.install_script}"))}"
  # }

  # download kubectl
  provisioner "local-exec" {
    command = "curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl && chmod +x kubectl"
  }

  # Install the ArgoCD YAML file.
  provisioner "local-exec" {
    command = "./kubectl apply -n ${kubernetes_namespace.ArgoCD.metadata[0].name} -f ${local.install_script}"

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
}

