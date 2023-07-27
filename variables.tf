# Setting the variables for ArgoCD installation

variable "kubeconfig" {
    type = string
}

variable "namespace" {
    type = string
    default       = "argocd"
}