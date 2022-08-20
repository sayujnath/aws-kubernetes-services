######################################################################################

#   Title:          Example   App AWS cloud resources
#   Author:         Sayuj Nath, Cloud Solutions Architect
#   Comapany:       Canditude
#                   Prepared for  public non-commercial use
#   Description:    Computing resources for
#                   development and deployment using AWS Load Balancer Controller (Ingress controller)
#   File Desc:      This module generates creates the example service and connects it to 
#                   a NodePOrt for external access.

#   Dependencies:   - example service communication information from the infra layer


# The following AWS resoucres are created by this Kuberneets manifest: 

#     - example service creation


# Kubernestes Manifests in Teraform were converted from YAML files using tfk8s


resource "kubernetes_manifest" "service_example_app_internal_master_example_api" {
    manifest = {
        "apiVersion" = "v1"
        "kind" = "Service"
        "metadata" = {
            "labels" = {
                "client" = var.client
            }
            "name" = "${var.client}-example-api"
            "namespace" = var.namespace
        }
        "spec" = {
            "ports" = [
                {
                "name" = "example-service"
                "port" = var.example_port
                "protocol" = "TCP"
                }
            ]
            "selector" = {
                "client" = var.client
            }
            "type" = "NodePort"
        }
    }
}