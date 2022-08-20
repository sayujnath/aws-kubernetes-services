variable "eks_cluster_name" {
    type = string
    description = "Name of k8S Cluster"
}

variable "region" {
    type    = string
   
}
variable "cloudwatch_log_retention"   {
    type = number
    description = "Number of days cloudwatch logs will retain data"
}