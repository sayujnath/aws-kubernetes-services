data "aws_iam_policy_document" "example_cluster_autoscaler_eks_service_account_role_policy" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.example_alb_ingress_controller-oicd-eks-connect.url, "https://", "")}:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.example_alb_ingress_controller-oicd-eks-connect.url, "https://", "")}:sub"
      values   = ["system:serviceaccount:kube-system:${var.cluster_autoscaler_name}"]
    }

    principals {
      identifiers = [aws_iam_openid_connect_provider.example_alb_ingress_controller-oicd-eks-connect.arn]
      type        = "Federated"
    }
  }
}


resource "aws_iam_role" "example_cluster_autoscaler_service_account_role" {
  assume_role_policy = data.aws_iam_policy_document.example_eks_service_account_role_policy.json
  name               = var.cluster_autoscaler_name
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