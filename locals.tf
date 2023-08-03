#Pin the paths used for storing the kubeconfig files. This needs to be updated whenever a new cluster is being added.

locals {
  root_dir               = dirname(abspath(path.root))
  kubeconf_path = "${local.root_dir}/.kube/kubeconfig.yaml"
  install_script = "https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml"
}

