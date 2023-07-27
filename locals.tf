#Pin the paths used for storing the kubeconfig files. This needs to be updated whenever a new cluster is being added.

locals {
  root_dir               = dirname(abspath(path.root))
  kubeconf_path = "${local.root_dir}/.kube/kubeconfig.yaml"
<<<<<<< HEAD
  install_script = "https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/core-install.yaml"
=======
  install_script = "./install.yaml" 
>>>>>>> 9304d576a2e91781d0fb77f909e343311d833264
}
