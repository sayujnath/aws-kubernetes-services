######################################################################################

#   Title:          Example   App AWS cloud resources
#   Author:         Sayuj Nath, Cloud Solutions Architect
#   Comapany:       Canditude
#                   Prepared for  public non-commercial use
#   Description:    Computing resources for
#                   development and deployment using AWS Load Balancer Controller (Ingress controller)
#   File Desc:      This module generates k8s pods updating Route 53
#                   DNS records. It cretes and deletes DNS records via the ingress deployment

#   Dependencies:   - Needs Route53 domain information to update.


# The following AWS resoucres are created by this Kuberneets manifest: 

#     - external-dns pod deployment
#     - service account and ClusterRole needed to deploy external-dns


# Kubernestes Manifests in Teraform were converted from YAML files using tfk8s


#                   This version of the code is incomplete &untested and specially released 
#                   for non-commecial public consumption. 

#                   For a production ready version,
#                   please contact the author at info@canditude.com
#                   Additional middleware is also required in application code to interact
#                   with the authorizaion servers 
#

resource "kubernetes_manifest" "serviceaccount_external_dns" {
    manifest = {
        "apiVersion" = "v1"
        "kind" = "ServiceAccount"

        "metadata" = {
            "name" = "external-dns"
            "namespace" = "kube-system"
        }
    }
}

resource "kubernetes_manifest" "clusterrole_external_dns" {
    
    manifest = {
        "apiVersion" = "rbac.authorization.k8s.io/v1"
        "kind" = "ClusterRole"
        "metadata" = {
        "name" = "external-dns"
        }
        "rules" = [
        {
            "apiGroups" = [
            "",
            ]
            "resources" = [
            "services",
            ]
            "verbs" = [
            "get",
            "watch",
            "list",
            ]
        },
        {
            "apiGroups" = [
            "",
            ]
            "resources" = [
            "pods",
            ]
            "verbs" = [
            "get",
            "watch",
            "list",
            ]
        },
        {
            "apiGroups" = [
            "extensions",
            ]
            "resources" = [
            "ingresses",
            ]
            "verbs" = [
            "get",
            "watch",
            "list",
            ]
        },
        {
            "apiGroups" = [
            "",
            ]
            "resources" = [
            "nodes",
            ]
            "verbs" = [
            "list",
            ]
        },
        ]
    }
}

resource "kubernetes_manifest" "cluster_role_binding_external_dns_viewer" {
    manifest = {
        "apiVersion" = "rbac.authorization.k8s.io/v1"
        "kind" = "ClusterRoleBinding"
        "metadata" = {
        "name" = "external-dns-viewer"
        }
        "roleRef" = {
        "apiGroup" = "rbac.authorization.k8s.io"
        "kind" = "ClusterRole"
        "name" = "external-dns"
        }
        "subjects" = [
        {
            "kind" = "ServiceAccount"
            "name" = "external-dns"
            "namespace" = "kube-system"
        },
        ]
    }
}

resource "kubernetes_manifest" "deployment_external_dns" {
    manifest = {
        "apiVersion" = "apps/v1"
        "kind" = "Deployment"
        "metadata" = {
            "name" = "external-dns"
            "namespace" = "kube-system"
        }
        "spec" = {
        "selector" = {
            "matchLabels" = {
            "app" = "external-dns"
            }
        }
        "strategy" = {
            "type" = "Recreate"
        }
        "template" = {
            "metadata" = {
            "labels" = {
                "app" = "external-dns"
            }
            }
            "spec" = {
                "dnsPolicy" = "Default"
                "containers" = [
                    {
                    "args" = [
                        "--source=ingress",
                        "--domain-filter= ${var.primary_domain}",
                        "--provider=aws",
                        # "--policy=upsert-only",       # aviod to ensure deletion of records on destry
                        "--aws-zone-type=public",
                        "--registry=txt",
                        "--txt-owner-id=${var.dns_identifier}",
                    ]
                    "image" = "bitnami/external-dns:0.7.1"
                    "name" = "external-dns"
                    },
                ]
                "securityContext" = {
                    "fsGroup" = 65534
                }
                "serviceAccountName" = "external-dns"
            }
        }
        }
    }
}