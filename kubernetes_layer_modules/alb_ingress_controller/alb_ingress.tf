######################################################################################

#   Title:          Example   App AWS cloud resources
#   Author:         Sayuj Nath, Cloud Solutions Architect
#   Comapany:       Canditude
#                   Prepared for  public non-commercial use
#   Description:    Computing resources for
#                   development and deployment using AWS Load Balancer Controller (Ingress controller)
#   File Desc:      This ALB is deployed with two listeners:
#                       - HTTP Listener at port 80 reditects to port 443
#                       - HTTPS Listener at port 443 redirects to the application deployments
#                   Web Application Firewall is enabled
#                   SSl certificate provided and managed by AWS Certificate Manager

#   Dependencies:   - Web Application Firewall Rules - passed in from the infra layer via var.waf_rules_arn
#                   - ACM certificate ARN - passed in from the infra layer via var.acm_certificate_arn


# Note: Traffic between the ALB and the example application is HTTP and non encrypted. This data is passed between
#       the web tier (public tier) and the application tier (private tier) within the vPC. To enable encrytion through
#       to the application, please enable application to listen for HTTPS requests and install a self-signed certificate

# The following AWS resoucres are created by this Kuberneets manifest: AWS ALB, Target groups with registered pod IP's

# The following resource is managed via Kubernetes manifests, deployed via Terraform.
#   SSL cert creation in ssl.terraform (uses ACM)
#   WAF Rules creation in separate module kubernetes_layer_modules/waf/waf.tf Terraform module.

# Kubernestes Manifests in Teraform were converted from YAML files using tfk8s

##
resource "kubernetes_manifest" "ingress_example_app_example_api_main_alb" {

    depends_on = [
                    helm_release.deployment_kube_system_alb_ingress_controller,
                    kubernetes_manifest.clusterrole_alb_ingress_controller,
                    aws_iam_role.example_alb_ingress_controller_service_account_role,
                    kubernetes_manifest.clusterrolebinding_alb_ingress_controller,
                    kubernetes_manifest.serviceaccount_example_alb_ingress_controller,
                    aws_iam_role_policy_attachment.example-alb-eks-cluster-AmazonEKSClusterPolicy,
                    aws_iam_role_policy_attachment.example-alb-eks-cluster-AmazonEKSServicePolicy,
                    aws_iam_role_policy_attachment.example-alb-eks-cluster-AmazonEKSVPCResourceController,
                    aws_iam_role_policy_attachment.example-alb-eks-cluster-AmazonVPCReadOnlyAccess,
                    aws_iam_role_policy_attachment.example-eks-cluster-alb-ingress-controller-role-policy,
                    aws_iam_policy.example_alb_ingress_controller_role_policy,
                ]
    
    manifest = {
        "apiVersion" = "networking.k8s.io/v1"
        "kind" = "Ingress"
        "metadata" = {
        "annotations" = {
            "alb.ingress.kubernetes.io/actions.ssl-redirect" = "{\"Type\": \"redirect\", \"RedirectConfig\": { \"Protocol\": \"HTTPS\", \"Port\": \"443\", \"StatusCode\": \"HTTP_301\"}}"
            "alb.ingress.kubernetes.io/security-groups"  = var.security_group_map.web.id 
            "alb.ingress.kubernetes.io/auth-on-unauthenticated-request" = "allow"
            "alb.ingress.kubernetes.io/backend-protocol" = "HTTP"
            "alb.ingress.kubernetes.io/certificate-arn" = var.acm_certificate_arn
            "alb.ingress.kubernetes.io/listen-ports" = "[{\"HTTP\": 80}, {\"HTTPS\":443}]"
            "alb.ingress.kubernetes.io/load-balancer-attributes" = "idle_timeout.timeout_seconds=3600"
            "alb.ingress.kubernetes.io/scheme" = "internet-facing"
            "alb.ingress.kubernetes.io/ssl-policy" = "ELBSecurityPolicy-TLS-1-1-2017-01"
            "alb.ingress.kubernetes.io/target-type" = "ip"    # To test with front end
            "alb.ingress.kubernetes.io/target-group-attributes" = "stickiness.enabled=true,stickiness.lb_cookie.duration_seconds=60"
            "external-dns.alpha.kubernetes.io/hostname" = "${var.api_subdomain}.${var.primary_domain}"
            "kubernetes.io/ingress.class" = "alb"
            "alb.ingress.kubernetes.io/tags": "Name=${var.alb_name}"
            "alb.ingress.kubernetes.io/target-group-attributes" = "load_balancing.algorithm.type=least_outstanding_requests"
            "alb.ingress.kubernetes.io/wafv2-acl-arn" = var.waf_rules_arn
        }
        "name" = var.alb_name
        "namespace" = var.example_namespace
        }
        "spec" = {
        "rules" = [
            {
            "host" = "${var.api_subdomain}.${var.primary_domain}"
            "http" = {
                "paths" = [
                {
                    "backend" = {
                    "service" = {
                        "name" = "ssl-redirect"
                        "port" = {
                        "name" = "use-annotation"
                        }
                    }
                    }
                    "path" = "/"
                    "pathType" = "Prefix"
                },
                {
                    "backend" = {
                    "service" = {
                        "name" = var.service_name
                        "port" = {
                        "number" = var.example_port
                        }
                    }
                    }
                    "path" = "/"
                    "pathType" = "Prefix"
                },
                ]
            }
            },
        ]
        "tls" = [
            {
            "hosts" = [
                "${var.api_subdomain}.${var.primary_domain}",
            ]
            "secretName" = "${var.service_name}-tls"
            },
        ]
        }
    }
}

