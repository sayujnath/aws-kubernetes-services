######################################################################################

#   Title:          Example   App AWS cloud resources
#   Author:         Sayuj Nath, Cloud Solutions Architect
#   Comapany:       Canditude
#                   Prepared for  public non-commercial use
#   Description:    Computing resources for
#                   development and deployment using AWS Load Balancer Controller (Ingress controller)
#   File Desc:      This module generates deploys the example pods into the
#                   K8S nodes using parameters passed in from the infra layer

#   Dependencies:   - EKS cluster information and example parameters from the infra layer


# The following AWS resoucres are created by this Kuberneets manifest: 

#     - example pod deployment
#     - example namespace created by the namespace module


# Kubernestes Manifests in Teraform were converted from YAML files using tfk8s


resource "kubernetes_manifest" "deployment_example_app__client_example_main" {
    
    field_manager   {
        force_conflicts = true
    }

    manifest = {
        "apiVersion" = "apps/v1"
        "kind" = "Deployment"
        "metadata" = {
            "labels" = {
                "client" = "${var.client}"
            }
            "name" = "${var.client}-example-main"
            "namespace" = var.namespace
        }
        "spec" = {
            "replicas" = 1
            "selector" = {
                "matchLabels" = {
                "client" = "${var.client}"
                }
            }
            "template" = {
                "metadata" = {
                "labels" = {
                    "client" = "${var.client}"
                }
                }
                "spec" = {
                "dnsPolicy" = "Default"     # This line is important to get multiple pods working. Removing it will cause pods unable to resolve MongoDB URLs
                "containers" = [
                    {
                    "env" = [
                        {
                        "name" = "EXAMPLE_ENVIRONMEMTAL_VARIABLE"
                        "value" = "${var.pod_env_variables.EXAMPLE_ENVIRONMEMTAL_VARIABLE}"
                        }
                    ]
                    "image" = var.ecr_image_location
                    "imagePullPolicy" = "Always"
                    "name" = "${var.client}-example-service"
                    "ports" = [
                        {
                        "containerPort" = var.example_port
                        "name" = "example-port"
                        "protocol" = "TCP"
                        },
                    ]
                    "resources" = {
                        "limits" = {
                        "memory" = var.example_resource_limit.memory
                        "cpu" = var.example_resource_limit.cpu
                        }
                    }
                    "securityContext" = {}
                    },
                ]
                "securityContext" = {}
                "serviceAccountName" = "default"
                }
            }
        }
    }
}