######################################################################################

#   Title:          Example   App AWS cloud resources
#   Author:         Sayuj Nath, Cloud Solutions Architect
#   Comapany:       Canditude
#                   Prepared for  public non-commercial use
#   Description:    Computing resources for
#                   development and deployment using AWS Load Balancer Controller (Ingress controller)
#   File Desc:      This module generates a namespace for the example service and pods

#   Dependencies:   - Needs EKs cluster information


# The following AWS resources are created by this Kuberneets manifest: 

#     - external-dns pod deployment
#     - service account and ClusterRole needed to deploy external-dns


# Kubernestes Manifests in Teraform were converted from YAML files using tfk8s


resource "kubernetes_namespace" "example_namespace" {

    metadata {
        annotations = {
        name = var.name
        }

        labels = {
            mylabel = var.name
        }

        name = var.name
    }

}