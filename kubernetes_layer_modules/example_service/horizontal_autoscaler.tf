######################################################################################

#   Title:          Example   App AWS cloud resources
#   Author:         Sayuj Nath, Cloud Solutions Architect
#   Comapany:       Canditude
#                   Prepared for  public non-commercial use
#   Description:    Computing resources for
#                   development and deployment using AWS Load Balancer Controller (Ingress controller)
#   File Desc:      This module generates deploys horizontal pod autoscalar (HPA)
#                   in order to ensure there are enough pods to handle incoming load.

#   Dependencies:   - example service inforation from the infra layer


# The following AWS resoucres are created by this Kuberneets manifest: 

#     - Horizontal Pod Autoscalar (HPA)




resource "kubernetes_horizontal_pod_autoscaler" "example_auto_scaler" {
  metadata {
    name = "${var.client}-horizontal-autoscaler"
    namespace = var.namespace
  }

  spec {
    max_replicas = var.pod_replicas_settings.max_replicas
    min_replicas = var.pod_replicas_settings.min_replicas
    target_cpu_utilization_percentage = var.pod_replicas_settings.target_cpu_utilization_percentage

    scale_target_ref {
      kind = "Deployment"
      name = "${var.client}-example-main"
      api_version =  "apps/v1"
    }
  }
}