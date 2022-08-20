######################################################################################

#   Title:          Example   App AWS cloud resources
#   Author:         Sayuj Nath, Cloud Solutions Architect
#   Comapany:       Canditude
#                   Prepared for  public non-commercial use
#   Description:    Computing resources for
#                   development and deployment using AWS Load Balancer Controller (Ingress controller)
#   File Desc:      Metrics server required by the HPA to make pod scaling decisions.


#   Dependencies:   - EKS Cluster information from the infra layer

# The following AWS resoucres are created by this Kuberneets manifest: 

#     - K8S metrics server


# Kubernetes Manifests in Teraform were converted from YAML files using tfk8s


resource "kubernetes_manifest" "serviceaccount_kube_system_metrics_server" {
  manifest = {
    "apiVersion" = "v1"
    "kind" = "ServiceAccount"
    "metadata" = {
      "labels" = {
        "k8s-app" = "metrics-server"
      }
      "name" = "metrics-server"
      "namespace" = "kube-system"
    }
  }
}

resource "kubernetes_manifest" "clusterrole_system_aggregated_metrics_reader" {
  manifest = {
    "apiVersion" = "rbac.authorization.k8s.io/v1"
    "kind" = "ClusterRole"
    "metadata" = {
      "labels" = {
        "k8s-app" = "metrics-server"
        "rbac.authorization.k8s.io/aggregate-to-admin" = "true"
        "rbac.authorization.k8s.io/aggregate-to-edit" = "true"
        "rbac.authorization.k8s.io/aggregate-to-view" = "true"
      }
      "name" = "system:aggregated-metrics-reader"
    }
    "rules" = [
      {
        "apiGroups" = [
          "metrics.k8s.io",
        ]
        "resources" = [
          "pods",
          "nodes",
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

resource "kubernetes_manifest" "clusterrole_system_metrics_server" {
  manifest = {
    "apiVersion" = "rbac.authorization.k8s.io/v1"
    "kind" = "ClusterRole"
    "metadata" = {
      "labels" = {
        "k8s-app" = "metrics-server"
      }
      "name" = "system:metrics-server"
    }
    "rules" = [
      {
        "apiGroups" = [
          "",
        ]
        "resources" = [
          "nodes/metrics",
        ]
        "verbs" = [
          "get",
        ]
      },
      {
        "apiGroups" = [
          "",
        ]
        "resources" = [
          "pods",
          "nodes",
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

resource "kubernetes_manifest" "rolebinding_kube_system_metrics_server_auth_reader" {
  manifest = {
    "apiVersion" = "rbac.authorization.k8s.io/v1"
    "kind" = "RoleBinding"
    "metadata" = {
      "labels" = {
        "k8s-app" = "metrics-server"
      }
      "name" = "metrics-server-auth-reader"
      "namespace" = "kube-system"
    }
    "roleRef" = {
      "apiGroup" = "rbac.authorization.k8s.io"
      "kind" = "Role"
      "name" = "extension-apiserver-authentication-reader"
    }
    "subjects" = [
      {
        "kind" = "ServiceAccount"
        "name" = "metrics-server"
        "namespace" = "kube-system"
      },
    ]
  }
}

resource "kubernetes_manifest" "clusterrolebinding_metrics_server_system_auth_delegator" {
  manifest = {
    "apiVersion" = "rbac.authorization.k8s.io/v1"
    "kind" = "ClusterRoleBinding"
    "metadata" = {
      "labels" = {
        "k8s-app" = "metrics-server"
      }
      "name" = "metrics-server:system:auth-delegator"
    }
    "roleRef" = {
      "apiGroup" = "rbac.authorization.k8s.io"
      "kind" = "ClusterRole"
      "name" = "system:auth-delegator"
    }
    "subjects" = [
      {
        "kind" = "ServiceAccount"
        "name" = "metrics-server"
        "namespace" = "kube-system"
      },
    ]
  }
}

resource "kubernetes_manifest" "clusterrolebinding_system_metrics_server" {
  manifest = {
    "apiVersion" = "rbac.authorization.k8s.io/v1"
    "kind" = "ClusterRoleBinding"
    "metadata" = {
      "labels" = {
        "k8s-app" = "metrics-server"
      }
      "name" = "system:metrics-server"
    }
    "roleRef" = {
      "apiGroup" = "rbac.authorization.k8s.io"
      "kind" = "ClusterRole"
      "name" = "system:metrics-server"
    }
    "subjects" = [
      {
        "kind" = "ServiceAccount"
        "name" = "metrics-server"
        "namespace" = "kube-system"
      },
    ]
  }
}

resource "kubernetes_manifest" "service_kube_system_metrics_server" {
  manifest = {
    "apiVersion" = "v1"
    "kind" = "Service"
    "metadata" = {
      "labels" = {
        "k8s-app" = "metrics-server"
      }
      "name" = "metrics-server"
      "namespace" = "kube-system"
    }
    "spec" = {
      "ports" = [
        {
          "name" = "https"
          "port" = 443
          "protocol" = "TCP"
          "targetPort" = "https"
        },
      ]
      "selector" = {
        "k8s-app" = "metrics-server"
      }
    }
  }
}

resource "kubernetes_manifest" "deployment_kube_system_metrics_server" {
  manifest = {
    "apiVersion" = "apps/v1"
    "kind" = "Deployment"
    "metadata" = {
      "labels" = {
        "k8s-app" = "metrics-server"
      }
      "name" = "metrics-server"
      "namespace" = "kube-system"
    }
    "spec" = {
      "selector" = {
        "matchLabels" = {
          "k8s-app" = "metrics-server"
        }
      }
      "strategy" = {
        "rollingUpdate" = {
          "maxUnavailable" = 0
        }
      }
      "template" = {
        "metadata" = {
          "labels" = {
            "k8s-app" = "metrics-server"
          }
        }
        "spec" = {
          "containers" = [
            {
              "args" = [
                "--cert-dir=/tmp",
                "--secure-port=4443",
                "--kubelet-insecure-tls=true",
                "--kubelet-preferred-address-types=InternalIP,ExternalIP,Hostname",
                "--kubelet-use-node-status-port",
                "--metric-resolution=15s",
              ]
              "image" = "k8s.gcr.io/metrics-server/metrics-server:v0.6.1"
              "imagePullPolicy" = "IfNotPresent"
              "livenessProbe" = {
                "failureThreshold" = 3
                "httpGet" = {
                  "path" = "/livez"
                  "port" = "https"
                  "scheme" = "HTTPS"
                }
                "periodSeconds" = 10
              }
              "name" = "metrics-server"
              "ports" = [
                {
                  "containerPort" = 4443
                  "name" = "https"
                  "protocol" = "TCP"
                },
              ]
              "readinessProbe" = {
                "failureThreshold" = 3
                "httpGet" = {
                  "path" = "/readyz"
                  "port" = "https"
                  "scheme" = "HTTPS"
                }
                "initialDelaySeconds" = 20
                "periodSeconds" = 10
              }
              "resources" = {
                "requests" = {
                  "cpu" = "100m"
                  "memory" = "200Mi"
                }
              }
              "securityContext" = {
                "allowPrivilegeEscalation" = false
                "readOnlyRootFilesystem" = true
                "runAsNonRoot" = true
                "runAsUser" = 1000
              }
              "volumeMounts" = [
                {
                  "mountPath" = "/tmp"
                  "name" = "tmp-dir"
                },
              ]
            },
          ]
          "nodeSelector" = {
            "kubernetes.io/os" = "linux"
          }
          "priorityClassName" = "system-cluster-critical"
          "serviceAccountName" = "metrics-server"
          "volumes" = [
            {
              "emptyDir" = {}
              "name" = "tmp-dir"
            },
          ]
        }
      }
    }
  }
}

resource "kubernetes_manifest" "apiservice_v1beta1_metrics_k8s_io" {
  manifest = {
    "apiVersion" = "apiregistration.k8s.io/v1"
    "kind" = "APIService"
    "metadata" = {
      "labels" = {
        "k8s-app" = "metrics-server"
      }
      "name" = "v1beta1.metrics.k8s.io"
    }
    "spec" = {
      "group" = "metrics.k8s.io"
      "groupPriorityMinimum" = 100
      "insecureSkipTLSVerify" = true
      "service" = {
        "name" = "metrics-server"
        "namespace" = "kube-system"
      }
      "version" = "v1beta1"
      "versionPriority" = 100
    }
  }
}
