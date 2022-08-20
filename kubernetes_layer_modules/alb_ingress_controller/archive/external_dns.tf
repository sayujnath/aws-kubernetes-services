


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
            "containers" = [
                {
                "args" = [
                    "--source=ingress",
                    "--domain-filter= ${var.primary_domain}",
                    "--provider=aws",
                    "--policy=upsert-only",
                    "--aws-zone-type=public",
                    "--registry=txt",
                    "--txt-owner-id=my-identifier",
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