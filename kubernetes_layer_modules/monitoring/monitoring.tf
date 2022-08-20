######################################################################################

#   Title:          Example   App AWS cloud resources
#   Author:         Sayuj Nath, Cloud Solutions Architect
#   Comapany:       Canditude
#                   Prepared for  public non-commercial use
#   Description:    Computing resources for
#                   development and deployment using AWS Load Balancer Controller (Ingress controller)
#   File Desc:      This creates the following K8S resources:
#                     - Cloudwatch fluent-bit to send container logs to cloudwatch
#                     - CloudWatch metrics ent to send pod metrics to CloudWatch container Insights 
#                     - for browser based K8S monitoring


#   Dependencies:   - EKS Cluster information from the infra layer

# The following AWS resoucres are created by helm charts: 

#     - Cloudwatch fluent-bit
#     - CloudWatch metrics



locals {
    FluentBitHttpServer = "On"
    FluentBitHttpPort = "2020"
    FluentBitReadFromHead = "Off"
    FluentBitReadFromTail = "On"

    log_group_name = "/aws/eks/${var.eks_cluster_name}/fluentbit-cloudwatch/logs"

    namespace = "amazon-cloudwatch"
}


resource "kubernetes_namespace" "cloudwatch_namespace" {
    metadata {

        labels = {
            name = local.namespace
        }

        name = local.namespace
    }
}

resource "time_sleep" "wait_30_seconds" {
  depends_on = [kubernetes_namespace.cloudwatch_namespace]

  destroy_duration = "30s"
}


resource "aws_cloudwatch_log_group" "fluent_bit_log" {
  name              =  	local.log_group_name
  retention_in_days = var.cloudwatch_log_retention
}


resource "helm_release" "fluent-bit" {
 depends_on = [ aws_cloudwatch_log_group.fluent_bit_log ]
  name       = "log-server"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-for-fluent-bit"
  version   = "0.1.16"

  
  namespace = local.namespace

  set {
    name  = "cloudWatch.region"
    value =   var.region
  }

  set {
    name = "cloudWatch.logGroupName"
    value = "/aws/eks/${var.eks_cluster_name}/fluentbit-cloudwatch/logs"
  }


  set {
    name = "cloudWatch.enabled"
    value = "true"
  }

  set {
    name = "kinesis.enabled"
    value = "false"
  }

   set {
    name = "firehose.enabled"
    value = "false"
  }

  set {
    name = "elasticsearch.enabled"
    value = "false"
  }

 

}

resource "aws_cloudwatch_log_group" "cloudwatch-agent" {
  name              =  	"/aws/containerinsights/${var.eks_cluster_name}/performance"
  retention_in_days = var.cloudwatch_log_retention
}

resource "helm_release" "cloudwatch-agent" {
  depends_on = [ aws_cloudwatch_log_group.cloudwatch-agent ]
  name       = "cloudwatch-agent"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-cloudwatch-metrics"
  version    = "0.0.7"

  namespace  = local.namespace

  set {
    name  = "clusterName"
    value =   var.eks_cluster_name
  }

}
