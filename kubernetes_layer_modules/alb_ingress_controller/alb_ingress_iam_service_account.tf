######################################################################################

#   Title:          Example   App AWS cloud resources
#   Author:         Sayuj Nath, Cloud Solutions Architect
#   Comapany:       Canditude
#                   Prepared for  public non-commercial use
#   Description:    Computing resources for
#                   development and deployment using AWS Load Balancer Controller
#   File Desc:      IAM role and policies for k8S ALB Load Balancer controller service role 
#                    

#   Dependencies:   - Requires OICD connection URL from the infra layer

#   The following AWS resources are created via AWS provider
#       - IAM role and policies for k8S service role


##
locals {
    iam_policy_path =  "${path.module}/../../iam_policies"
    service_account =  "${var.alb_name}-sa"
}

data "aws_iam_policy_document" "example_eks_service_account_role_policy" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test     = "StringEquals"
      variable = "${replace(var.eks_oicd_connect_info.openid_connect_url, "https://", "")}:aud"
      values   = ["sts.amazonaws.com"]
    }

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

resource "aws_iam_role" "example_alb_ingress_controller_service_account_role" {
  assume_role_policy = data.aws_iam_policy_document.example_eks_service_account_role_policy.json
  name               = local.service_account
}

resource "aws_iam_role_policy_attachment" "example-alb-eks-cluster-AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.example_alb_ingress_controller_service_account_role.name
}

resource "aws_iam_role_policy_attachment" "example-alb-eks-cluster-AmazonEKSServicePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = aws_iam_role.example_alb_ingress_controller_service_account_role.name
}

resource "aws_iam_role_policy_attachment" "example-alb-eks-cluster-AmazonEKSVPCResourceController" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  role       = aws_iam_role.example_alb_ingress_controller_service_account_role.name
}

resource "aws_iam_role_policy_attachment" "example-alb-eks-cluster-AmazonVPCReadOnlyAccess" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonVPCReadOnlyAccess"
  role       = aws_iam_role.example_alb_ingress_controller_service_account_role.name
}



resource "aws_iam_role_policy_attachment" "example-eks-cluster-alb-ingress-controller-role-policy" {
  policy_arn = aws_iam_policy.example_alb_ingress_controller_role_policy.arn
  role       = aws_iam_role.example_alb_ingress_controller_service_account_role.name
}


resource "aws_iam_policy" "example_alb_ingress_controller_role_policy" {
    name = "${var.eks_oicd_connect_info.eks_cluster_name}-alb-ingress-controller-role-policy"
    description = "This policy gives the example EKS cluster ability to create and destroy ALB ingres resources as well as add DNS records in route 53"
    policy =  templatefile("${local.iam_policy_path}/example_alb_ingress_controller_role_policy.json", {primary_domain_host_zone_id = var.primary_domain_host_zone_id})
}