######################################################################################

#   Title:          Example   App AWS cloud resources
#   Author:         Sayuj Nath, Cloud Solutions Architect
#   Comapany:       Canditude
#                   Prepared for  public non-commercial use
#   Description:    Computing resources for
#                   development and deployment using AWS Load Balancer Controller (Ingress controller)
#   File Desc:      This module generates k8s pods for the cluster autoscalar, which
#                   scales the number of EKS nodes based on load (ie. number of pods)

#   Dependencies:   - Needs EKS cluster information to run on


# The following AWS resoucres are created by this Kuberneets manifest: 

#     - Cluster Role and Service account to operate the CA.


# Kubernestes Manifests in Teraform were converted from YAML files using tfk8s



locals {
    iam_policy_path =  "${path.module}/../../iam_policies"
    service_account = var.cluster_autoscaler_name
}


resource "aws_iam_role" "example_cluster_autoscaler_service_account_role" {
  assume_role_policy = data.aws_iam_policy_document.example_cluster_autoscaler_eks_service_account_role_policy.json
  name               = local.service_account
}


data "aws_iam_policy_document" "example_cluster_autoscaler_eks_service_account_role_policy" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    # condition {
    #   test     = "StringEquals"
    #   variable = "${replace(var.eks_oicd_connect_info.openid_connect_url, "https://", "")}:aud"
    #   values   = ["sts.amazonaws.com"]
    # }

    condition {
      test     = "StringEquals"
      variable = "${replace(var.eks_oicd_connect_info.openid_connect_url, "https://", "")}:sub"
      values   = ["system:serviceaccount:kube-system:${local.service_account}"]
    }

    principals {
      identifiers = [var.eks_oicd_connect_info.openid_connect_arn]
      type        = "Federated"
    }
  }
}


resource "aws_iam_role_policy_attachment" "example_cluster_autoscaler_role_policy" {
  policy_arn = aws_iam_policy.example_cluster_autoscaler_role_policy.arn
  role       = aws_iam_role.example_cluster_autoscaler_service_account_role.name
}


resource "aws_iam_policy" "example_cluster_autoscaler_role_policy" {
    name = "${var.eks_oicd_connect_info.eks_cluster_name}-cluster-autoscaler-role-policy"
    description = "This policy gives the cluster-autoacaler pod ability to autoscale the number of nodes in the clusters"
    policy =  templatefile("${local.iam_policy_path}/example_cluster_autoscaling_policy.json", {eks_cluster_name = var.eks_oicd_connect_info.eks_cluster_name})
}