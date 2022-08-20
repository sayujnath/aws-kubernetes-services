######################################################################################

#   Title:          Example   App AWS cloud resources
#   Author:         Sayuj Nath, Cloud Solutions Architect
#   Comapany:       Canditude
#                   Prepared for  public non-commercial use
#   Description:    Computing resources for
#                   development and deployment using AWS
#                   public cloud resources.
#   File Desc:      The main setup for the  kubernetes layer which 
#                   deploys the following modules that create K8S resources:
#                   - example Namespace 
#                   - Monitoring  (Cloudwatch)
#                   - Route53 DNS  (External-DNS)
#                   - example Service with Horizonal Pod Autoscaling (HPA)
#                   - Monitoring
#                   - Cluster Autoscaling
#                   - Application Load Balancer Controller

#   Dependencies:   - Requires this setup's Infra Layer to be deployed beforehand

# The following resources are managed via Kubernetes manifests and helm charts,
# This was done to repurpose existing technical debt.
#                   - example Namespace 
#                   - Monitoring  (Cloudwatch)
#                   - Route53 DNS  (External-DNS)
#                   - example Service with Horizonal Pod Autoscaling (HPA)
#                   - Monitoring
#                   - Cluster Autoscaling
#                   - Application Load Balancer Controller



#                   This version of the code is incomplete &untested and specially released 
#                   for non-commecial public consumption. 

#                   For a production ready version,
#                   please contact the author at info@canditude.com
#                   Additional middleware is also required in application code to interact
#                   with the authorizaion servers 
#

#######################################################################################


locals {
  namespace  = "example_app"
  app_memory_limit = "2Gi"
  app_cpu_limit = "800m"
  min_pods = 3
  max_pods = 10
  target_cpu_percentage = 60
}


module "namespace"  {

    source = "../../../kubernetes_layer_modules/namespace"
    name = local.namespace
}



module "external-dns" {

    source = "../../../kubernetes_layer_modules/external-dns"
    primary_domain = data.terraform_remote_state.eks.outputs.primary_domain
    dns_identifier = data.terraform_remote_state.eks.outputs.eks_oicd_connect_info.eks_cluster_name
}

module "example_service" {

  depends_on = [
      module.namespace,
      module.external-dns
  ]
  source = "../../../kubernetes_layer_modules/example_service"

  client = data.terraform_remote_state.eks.outputs.client
  pod_env_variables = data.terraform_remote_state.eks.outputs.pod_env_variables
  ecr_image_location = data.terraform_remote_state.eks.outputs.ecr_image_location
  namespace = local.namespace
  example_port = tonumber(data.terraform_remote_state.eks.outputs.pod_env_variables.PORT)
  database_connection_string = base64decode(data.terraform_remote_state.eks.outputs.database_connection_string)

  health_check_path = data.terraform_remote_state.eks.outputs.health_check_path
  pod_replicas_settings ={ 
    max_replicas = local.max_pods, 
    min_replicas = local.min_pods, 
    target_cpu_utilization_percentage = local.target_cpu_percentage
    }

  example_resource_limit = {
    memory = local.app_memory_limit
    cpu = local.app_cpu_limit
  }
}


module "cluster-autoscalar" {
  depends_on = [
      module.example_service,
  ]

    source = "../../../kubernetes_layer_modules/cluster-autoscaler"

    eks_oicd_connect_info = data.terraform_remote_state.eks.outputs.eks_oicd_connect_info
    cluster_autoscaler_name = "${data.terraform_remote_state.eks.outputs.eks_oicd_connect_info.eks_cluster_name}-cluster-autoscaler"

}

module "monitoring" {

    depends_on = [
      module.example_service,
    ]

    source = "../../../kubernetes_layer_modules/monitoring"

    cloudwatch_log_retention = data.terraform_remote_state.eks.outputs.cloudwatch_log_retention
    region = data.terraform_remote_state.eks.outputs.region
    eks_cluster_name = data.terraform_remote_state.eks.outputs.eks_oicd_connect_info.eks_cluster_name

}



# ALB Load Balancer Controller (Implemented as Heml Chart module.monitoring)
# Be cautious when upgrading versions
module "alb_ingress_controller" {
  depends_on = [
      module.example_service,
      module.external-dns,
      module.cluster-autoscalar,
      module.monitoring,
  ]

    source = "../../../kubernetes_layer_modules/alb_ingress_controller"

    account_number = data.terraform_remote_state.eks.outputs.account_number
    eks_oicd_connect_info = data.terraform_remote_state.eks.outputs.eks_oicd_connect_info
    alb_name = "${data.terraform_remote_state.eks.outputs.eks_oicd_connect_info.eks_cluster_name}-alb"
    cluster_autoscaler_name = module.cluster-autoscalar.cluster_autoscaler_name

    region = data.terraform_remote_state.eks.outputs.region

    vpc_id = data.terraform_remote_state.eks.outputs.vpc_id
    subnet_map = data.terraform_remote_state.eks.outputs.subnet_map
    security_group_map = data.terraform_remote_state.eks.outputs.security_group_map

    primary_domain = data.terraform_remote_state.eks.outputs.primary_domain
    primary_domain_host_zone_id = data.terraform_remote_state.eks.outputs.primary_domain_host_zone_id

    api_subdomain = "${data.terraform_remote_state.eks.outputs.client}.${data.terraform_remote_state.eks.outputs.client_subdomain}"
    service_name = "${data.terraform_remote_state.eks.outputs.client}-example-api"
    
    example_port = tonumber(data.terraform_remote_state.eks.outputs.pod_env_variables.PORT)
    
    example_namespace = local.namespace
    tags = data.terraform_remote_state.eks.outputs.default_tags
    waf_rules_arn = data.terraform_remote_state.eks.outputs.waf_rules_arn

    acm_certificate_arn = data.terraform_remote_state.eks.outputs.acm_certificate_arn

}


