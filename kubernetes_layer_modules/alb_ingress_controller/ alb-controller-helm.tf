######################################################################################

#   Title:          Example   App AWS cloud resources
#   Author:         Sayuj Nath, Cloud Solutions Architect
#   Comapany:       Canditude
#                   Prepared for  public non-commercial use
#   Description:    Computing resources for
#                   development and deployment using AWS Load Balancer Controller
#   File Desc:      This AWS Load Balancer Contoller create the ALB in the web tier. 
#                    

#   Dependencies:   - IAM Roles and permissions for service accounts and cluster role. These are in alb_ingress_iam_service_account.tf
#                   - subnets in the web tier in module infra_layer/modules/network/subnets.tf has been tagged in the 
#                     with "kubernetes.io/role/elb"="1" and  "kubernetes.io/cluster/${var.k8s_cluster_name}" = "shared"
#                     This is to make the subnets discoverable by the ALB.


#   The following Kubernetes resources are created via Helm Chart
#       - AWS Load Balancer Controller - Please update version if updating Kubernetes (EKS) cluster

#   The following Kubernetes resources are managed via Kubernetes manifests, deployed via Terraform.
#       - Cluster Role for the Load Balancer Controller
#       - Service account for the Load Balancer Controller - IAM roles in separate file - alb_ingress_iam_service_account.tf


# Kubernestes Manifests in Terraform were converted from YAML files using tfk8s

##

resource "helm_release" "deployment_kube_system_alb_ingress_controller" {
    depends_on = [
                    aws_iam_role.example_alb_ingress_controller_service_account_role,
                    kubernetes_manifest.clusterrole_alb_ingress_controller, 
                    kubernetes_manifest.clusterrolebinding_alb_ingress_controller,
                    kubernetes_manifest.serviceaccount_example_alb_ingress_controller,
                    aws_iam_role_policy_attachment.example-alb-eks-cluster-AmazonEKSClusterPolicy,
                    aws_iam_role_policy_attachment.example-alb-eks-cluster-AmazonEKSServicePolicy,
                    aws_iam_role_policy_attachment.example-alb-eks-cluster-AmazonEKSVPCResourceController,
                    aws_iam_role_policy_attachment.example-alb-eks-cluster-AmazonVPCReadOnlyAccess,
                    aws_iam_role_policy_attachment.example-eks-cluster-alb-ingress-controller-role-policy,
                    aws_iam_policy.example_alb_ingress_controller_role_policy,
                ]
    name       = var.alb_name
    repository = "https://aws.github.io/eks-charts"
    chart      = "aws-load-balancer-controller"
    version    = "1.4.2"
    namespace  = "kube-system"


    set {
        name  = "vpcId"
        value =   var.vpc_id
    }

    set {
        name  = "region"
        value =   var.region
    }

    set {
        name  = "clusterName"
        value =   var.eks_oicd_connect_info.eks_cluster_name
    }

    set {
        name  = "backendSecurityGroup"
        value =   var.security_group_map.web.id
    }


    set {
        name  = "enablebackendSecurityGroup"
        value =   false
    }

    set {
        name  = "serviceAccount.name"
        value =   local.service_account
    }

    set {
        name  = "serviceAccount.create"
        value =   false
    }

    set {
        name = "dnsPolicy"
        value = "Default"
    }
}

#   Cluster Role for the Load Balancer Controller
resource "kubernetes_manifest" "clusterrole_alb_ingress_controller" {
    manifest = {
        "apiVersion" = "rbac.authorization.k8s.io/v1"
        "kind" = "ClusterRole"
        "metadata" = {
        "labels" = {
            "app.kubernetes.io/name" = "aws-load-balancer-controller"
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

# Service account for the Load Balancer Controller - IAM roles in separate file - alb_ingress_iam_service_account.tf
resource "kubernetes_manifest" "clusterrolebinding_alb_ingress_controller" {
    manifest = {
        "apiVersion" = "rbac.authorization.k8s.io/v1"
        "kind" = "ClusterRoleBinding"
        "metadata" = {
        "labels" = {
            "app.kubernetes.io/name" = "aws-load-balancer-controller"
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
            "name" = local.service_account
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
            "app.kubernetes.io/name" = "aws-load-balancer-controller"
        }
        "name" = local.service_account
        "namespace" = "kube-system"
        }
    }
}
