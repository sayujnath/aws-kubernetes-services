
variable eks_oicd_connect_info  {
    type = map
    description = "This information is used to connect the OICD providor with EKS for K8S service accounts. The format of this is a follows {eks_cluste_rname, thumbprint, issuer_url}"
}


variable "cluster_autoscaler_name" {
    type = string
    description = "The name of the cluster auto scaler"
}
