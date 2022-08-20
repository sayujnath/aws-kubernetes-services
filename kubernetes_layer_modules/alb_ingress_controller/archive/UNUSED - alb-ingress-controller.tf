resource "kubernetes_manifest" "deployment_kube_system_alb_ingress_controller" {

  depends_on = [
                    aws_acm_certificate.alb_ssl_primary_cert,
                    kubernetes_manifest.clusterrole_alb_ingress_controller,
                    kubernetes_manifest.ingress_example_app_example_api_main_alb    # This is important because the ingress can only be deleted after the controller. Otherwise the finalizer kicks in and prevents the ingress from deleted.
                # null_resource.remove_finalizer
                ]

  manifest = {
    "apiVersion" = "apps/v1"
    "kind" = "Deployment"
    "metadata" = {
      "labels" = {
        "app.kubernetes.io/name" = var.alb_name
      }
      "name" = var.alb_name
      "namespace" = "kube-system"
    }
    "spec" = {
      "selector" = {
        "matchLabels" = {
          "app.kubernetes.io/name" = var.alb_name
        }
      }
      "template" = {
        "metadata" = {
          "labels" = {
            "app.kubernetes.io/name" = var.alb_name
          }
        }
        "spec" = {
          "containers" = [
            {
              "args" = [
                "--ingress-class=alb",
                "--cluster-name=${var.eks_oicd_connect_info.eks_cluster_name}",
                "--aws-vpc-id=${var.vpc_id}",
                "--aws-region=${var.region}",
                "--aws-api-debug",
              ]
              "env" = null
              "image" = "docker.io/amazon/aws-alb-ingress-controller:v1.1.9"
              "name" = var.alb_name
            },
          ]
          "serviceAccountName" = var.alb_name
        }
      }
    }
  }
}

resource "kubernetes_manifest" "clusterrole_alb_ingress_controller" {
    manifest = {
        "apiVersion" = "rbac.authorization.k8s.io/v1"
        "kind" = "ClusterRole"
        "metadata" = {
        "labels" = {
            "app.kubernetes.io/name" = var.alb_name
        }
        "name" = var.alb_name
        }
        "rules" = [
        {
            "apiGroups" = [
            "",
            "extensions",
            ]
            "resources" = [
            "configmaps",
            "endpoints",
            "events",
            "ingresses",
            "ingresses/status",
            "services",
            "pods/status",
            ]
            "verbs" = [
            "create",
            "get",
            "list",
            "update",
            "watch",
            "patch",
            ]
        },
        {
            "apiGroups" = [
            "",
            "extensions",
            ]
            "resources" = [
            "nodes",
            "pods",
            "secrets",
            "services",
            "namespaces",
            ]
            "verbs" = [
            "get",
            "list",
            "watch",
            ]
        },
        ]
    }
}

resource "kubernetes_manifest" "clusterrolebinding_alb_ingress_controller" {
    manifest = {
        "apiVersion" = "rbac.authorization.k8s.io/v1"
        "kind" = "ClusterRoleBinding"
        "metadata" = {
        "labels" = {
            "app.kubernetes.io/name" = var.alb_name
        }
        "name" =var.alb_name
        }
        "roleRef" = {
        "apiGroup" = "rbac.authorization.k8s.io"
        "kind" = "ClusterRole"
        "name" =var.alb_name
        }
        "subjects" = [
        {
            "kind" = "ServiceAccount"
            "name" = var.alb_name
            "namespace" = "kube-system"
        },
        ]
    }
}

resource "kubernetes_manifest" "serviceaccount_example_alb_ingress_controller" {
    manifest = {
        "apiVersion" = "v1"
        "kind" = "ServiceAccount"
        "metadata" = {
        "annotations" = {
            "eks.amazonaws.com/role-arn" = aws_iam_role.example_alb_ingress_controller_service_account_role.arn
        }
        "labels" = {
            "app.kubernetes.io/name" = var.alb_name
        }
        "name" = var.alb_name
        "namespace" = "kube-system"
        }
    }
}