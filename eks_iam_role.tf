locals {
  issuer_without_https = replace(aws_eks_cluster.cluster.identity[0].oidc[0].issuer, "https://", "")

}
output "oidc_issuer" {
  value = aws_eks_cluster.cluster.identity[0].oidc[0].issuer
}
output "issuer_without_https" {
  value = local.issuer_without_https
}

resource "aws_iam_role" "eksctl-zde-eks-cluster-ServiceRole" {
  assume_role_policy = <<POLICY
{
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Effect": "Allow",
      "Principal": {
        "Service": [
          "eks-fargate-pods.amazonaws.com",
          "eks.amazonaws.com"
        ]
      }
    }
  ],
  "Version": "2012-10-17"
}
POLICY

  inline_policy {
    name   = "eksctl-zde-${var.env}-eks-cluster-PolicyCloudWatchMetrics"
    policy = "{\"Version\":\"2012-10-17\",\"Statement\":[{\"Action\":[\"cloudwatch:PutMetricData\"],\"Resource\":\"*\",\"Effect\":\"Allow\"}]}"
  }

  inline_policy {
    name   = "eksctl-zde-${var.env}-eks-cluster-PolicyELBPermissions"
    policy = "{\"Version\":\"2012-10-17\",\"Statement\":[{\"Action\":[\"ec2:DescribeAccountAttributes\",\"ec2:DescribeAddresses\",\"ec2:DescribeInternetGateways\"],\"Resource\":\"*\",\"Effect\":\"Allow\"}]}"
  }

  managed_policy_arns  = ["arn:aws:iam::aws:policy/AmazonEKSClusterPolicy", "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"]
  max_session_duration = "3600"
  name                 = var.eks-cluster-ServiceRole
  path                 = "/"

  tags = {
    Environment                                   = "${var.env}"
    Group                                         = "${var.env}-shared"
    Name                                          = "eksctl-zde-${var.env}-eks-cluster/ServiceRole"
    "alpha.eksctl.io/cluster-name"                = "zde-${var.env}-eks"
    "alpha.eksctl.io/eksctl-version"              = "0.40.0-rc.0"
    "eksctl.cluster.k8s.io/v1alpha1/cluster-name" = "zde-${var.env}-eks"
  }

  tags_all = {
    Environment                                   = "${var.env}"
    Group                                         = "${var.env}-shared"
    Name                                          = "eksctl-zde-${var.env}-eks-cluster/ServiceRole"
    "alpha.eksctl.io/cluster-name"                = "zde-${var.env}-eks"
    "alpha.eksctl.io/eksctl-version"              = "0.40.0-rc.0"
    "eksctl.cluster.k8s.io/v1alpha1/cluster-name" = "zde-${var.env}-eks"
  }
}

resource "aws_iam_role" "eks-addon-iamserviceacco-Role" {
  assume_role_policy = <<POLICY
{
  "Statement": [
    {
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "${local.issuer_without_https}:aud": "sts.amazonaws.com",
          "${local.issuer_without_https}:sub": "system:serviceaccount:kube-system:aws-node"
        }
      },
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${local.issuer_without_https}}"
      }
    }
  ],
  "Version": "2012-10-17"
}
POLICY

  managed_policy_arns  = ["arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"]
  max_session_duration = "3600"
  name                 = var.eks-addon-iamserviceacco-Role
  path                 = "/"

  tags = {
    Environment                                   = "${var.env}"
    Group                                         = "${var.env}-shared"
    "alpha.eksctl.io/cluster-name"                = "zde-${var.env}-eks"
    "alpha.eksctl.io/eksctl-version"              = "0.40.0-rc.0"
    "alpha.eksctl.io/iamserviceaccount-name"      = "kube-system/aws-node"
    "eksctl.cluster.k8s.io/v1alpha1/cluster-name" = "zde-${var.env}-eks"
  }

  tags_all = {
    Environment                                   = "${var.env}"
    Group                                         = "${var.env}-shared"
    "alpha.eksctl.io/cluster-name"                = "zde-${var.env}-eks"
    "alpha.eksctl.io/eksctl-version"              = "0.40.0-rc.0"
    "alpha.eksctl.io/iamserviceaccount-name"      = "kube-system/aws-node"
    "eksctl.cluster.k8s.io/v1alpha1/cluster-name" = "zde-${var.env}-eks"
  }
}

resource "aws_iam_role" "eks-nodegroup-NodeInstanceRole" {
  assume_role_policy = <<POLICY
{
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      }
    }
  ],
  "Version": "2012-10-17"
}
POLICY

  managed_policy_arns  = ["arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly", "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"]
  max_session_duration = "3600"
  name                 = var.eks-no-NodeInstanceRole
  path                 = "/"

  tags = {
    Environment                                   = "${var.env}"
    Group                                         = "${var.env}-shared"
    Name                                          = "eksctl-zde-${var.env}-eks-nodegroup-zde-services/NodeInstanceRole"
    "alpha.eksctl.io/cluster-name"                = "zde-${var.env}-eks"
    "alpha.eksctl.io/eksctl-version"              = "0.40.0-rc.0"
    "alpha.eksctl.io/nodegroup-name"              = "zde-services"
    "alpha.eksctl.io/nodegroup-type"              = "managed"
    "eksctl.cluster.k8s.io/v1alpha1/cluster-name" = "zde-${var.env}-eks"
  }

  tags_all = {
    Environment                                   = "${var.env}"
    Group                                         = "${var.env}-shared"
    Name                                          = "eksctl-zde-${var.env}-eks-nodegroup-zde-services/NodeInstanceRole"
    "alpha.eksctl.io/cluster-name"                = "zde-${var.env}-eks"
    "alpha.eksctl.io/eksctl-version"              = "0.40.0-rc.0"
    "alpha.eksctl.io/nodegroup-name"              = "zde-services"
    "alpha.eksctl.io/nodegroup-type"              = "managed"
    "eksctl.cluster.k8s.io/v1alpha1/cluster-name" = "zde-${var.env}-eks"
  }
}

resource "aws_iam_role" "zde-eks-alb-role" {
  assume_role_policy = <<POLICY
{
  "Statement": [
    {
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "${local.issuer_without_https}:aud": "sts.amazonaws.com",
          "${local.issuer_without_https}:sub": "system:serviceaccount:kube-ingress:alb-ingress"
        }
      },
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${local.issuer_without_https}"
      }
    }
  ],
  "Version": "2012-10-17"
}
POLICY

  managed_policy_arns  = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/zde-${var.env}-alb-role"]
  max_session_duration = "3600"
  name                 = "zde-${var.env}-eks-alb-role"
  path                 = "/"

  tags = {
    Environment                                   = "${var.env}"
    Group                                         = "${var.env}-shared"
    "alpha.eksctl.io/cluster-name"                = "zde-${var.env}-eks"
    "alpha.eksctl.io/eksctl-version"              = "0.40.0-rc.0"
    "alpha.eksctl.io/iamserviceaccount-name"      = "kube-ingress/alb-ingress"
    "eksctl.cluster.k8s.io/v1alpha1/cluster-name" = "zde-${var.env}-eks"
  }

  tags_all = {
    Environment                                   = "${var.env}"
    Group                                         = "${var.env}-shared"
    "alpha.eksctl.io/cluster-name"                = "zde-${var.env}-eks"
    "alpha.eksctl.io/eksctl-version"              = "0.40.0-rc.0"
    "alpha.eksctl.io/iamserviceaccount-name"      = "kube-ingress/alb-ingress"
    "eksctl.cluster.k8s.io/v1alpha1/cluster-name" = "zde-${var.env}-eks"
  }
}

resource "aws_iam_role" "zde-eks-autoscaller-role" {
  assume_role_policy = <<POLICY
{
  "Statement": [
    {
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "${local.issuer_without_https}:aud": "sts.amazonaws.com",
          "${local.issuer_without_https}:sub": "system:serviceaccount:kube-system:cluster-autoscaler"
        }
      },
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${local.issuer_without_https}"
      }
    }
  ],
  "Version": "2012-10-17"
}
POLICY

  inline_policy {
    name   = "eksctl-zde-${var.env}-eks-addon-iamserviceaccount-kube-system-cluster-autoscaler-Policy1"
    policy = "{\"Version\":\"2012-10-17\",\"Statement\":[{\"Action\":[\"autoscaling:DescribeAutoScalingGroups\",\"autoscaling:DescribeAutoScalingInstances\",\"autoscaling:DescribeLaunchConfigurations\",\"autoscaling:DescribeTags\",\"autoscaling:SetDesiredCapacity\",\"autoscaling:TerminateInstanceInAutoScalingGroup\",\"ec2:DescribeLaunchTemplateVersions\"],\"Resource\":\"*\",\"Effect\":\"Allow\"}]}"
  }

  max_session_duration = "3600"
  name                 = "zde-${var.env}-eks-autoscaller-role"
  path                 = "/"

  tags = {
    Environment                                   = "${var.env}"
    Group                                         = "${var.env}-shared"
    "alpha.eksctl.io/cluster-name"                = "zde-${var.env}-eks"
    "alpha.eksctl.io/eksctl-version"              = "0.40.0-rc.0"
    "alpha.eksctl.io/iamserviceaccount-name"      = "kube-system/cluster-autoscaler"
    "eksctl.cluster.k8s.io/v1alpha1/cluster-name" = "zde-${var.env}-eks"
  }

  tags_all = {
    Environment                                   = "${var.env}"
    Group                                         = "${var.env}-shared"
    "alpha.eksctl.io/cluster-name"                = "zde-${var.env}-eks"
    "alpha.eksctl.io/eksctl-version"              = "0.40.0-rc.0"
    "alpha.eksctl.io/iamserviceaccount-name"      = "kube-system/cluster-autoscaler"
    "eksctl.cluster.k8s.io/v1alpha1/cluster-name" = "zde-${var.env}-eks"
  }
}

resource "aws_iam_role" "zde-eks-cloudwatch-role" {
  assume_role_policy = <<POLICY
{
  "Statement": [
    {
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "${local.issuer_without_https}:aud": "sts.amazonaws.com",
          "${local.issuer_without_https}:sub": "system:serviceaccount:amazon-cloudwatch:fluentd"
        }
      },
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${local.issuer_without_https}"
      }
    }
  ],
  "Version": "2012-10-17"
}
POLICY

  managed_policy_arns  = ["arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"]
  max_session_duration = "3600"
  name                 = "zde-${var.env}-eks-cloudwatch-role"
  path                 = "/"

  tags = {
    Environment                                   = "${var.env}"
    Group                                         = "${var.env}-shared"
    "alpha.eksctl.io/cluster-name"                = "zde-${var.env}-eks"
    "alpha.eksctl.io/eksctl-version"              = "0.40.0-rc.0"
    "alpha.eksctl.io/iamserviceaccount-name"      = "amazon-cloudwatch/fluentd"
    "eksctl.cluster.k8s.io/v1alpha1/cluster-name" = "zde-${var.env}-eks"
  }

  tags_all = {
    Environment                                   = "${var.env}"
    Group                                         = "${var.env}-shared"
    "alpha.eksctl.io/cluster-name"                = "zde-${var.env}-eks"
    "alpha.eksctl.io/eksctl-version"              = "0.40.0-rc.0"
    "alpha.eksctl.io/iamserviceaccount-name"      = "amazon-cloudwatch/fluentd"
    "eksctl.cluster.k8s.io/v1alpha1/cluster-name" = "zde-${var.env}-eks"
  }
}

resource "aws_iam_role" "zde-eks-dns-role" {
  assume_role_policy = <<POLICY
{
  "Statement": [
    {
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "${local.issuer_without_https}:aud": "sts.amazonaws.com",
          "${local.issuer_without_https}:sub": "system:serviceaccount:kube-ingress:external-dns"
        }
      },
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${local.issuer_without_https}"
      }
    }
  ],
  "Version": "2012-10-17"
}
POLICY

  #managed_policy_arns  = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/zde-${var.env}-external-dns-policy", "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/${var.env}_zone_change"]
  managed_policy_arns  = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/zde-${var.env}-external-dns-policy"]
  max_session_duration = "3600"
  name                 = "zde-${var.env}-eks-dns-role"
  path                 = "/"

  tags = {
    Environment                                   = "${var.env}"
    Group                                         = "${var.env}-shared"
    "alpha.eksctl.io/cluster-name"                = "zde-${var.env}-eks"
    "alpha.eksctl.io/eksctl-version"              = "0.40.0-rc.0"
    "alpha.eksctl.io/iamserviceaccount-name"      = "kube-ingress/external-dns"
    "eksctl.cluster.k8s.io/v1alpha1/cluster-name" = "zde-${var.env}-eks"
  }

  tags_all = {
    Environment                                   = "${var.env}"
    Group                                         = "${var.env}-shared"
    "alpha.eksctl.io/cluster-name"                = "zde-${var.env}-eks"
    "alpha.eksctl.io/eksctl-version"              = "0.40.0-rc.0"
    "alpha.eksctl.io/iamserviceaccount-name"      = "kube-ingress/external-dns"
    "eksctl.cluster.k8s.io/v1alpha1/cluster-name" = "zde-${var.env}-eks"
  }
}

resource "aws_iam_role" "zde-eks-tls-role" {
  assume_role_policy = <<POLICY
{
  "Statement": [
    {
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "${local.issuer_without_https}:aud": "sts.amazonaws.com",
          "${local.issuer_without_https}:sub": "system:serviceaccount:cert-manager:cert-manager"
        }
      },
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${local.issuer_without_https}"
      }
    }
  ],
  "Version": "2012-10-17"
}
POLICY

  #managed_policy_arns  = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/${var.env}_zone_change", "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/zde-${var.env}-external-dns-policy"]
  managed_policy_arns  = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/zde-${var.env}-external-dns-policy"]
  max_session_duration = "3600"
  name                 = "zde-${var.env}-eks-tls-role"
  path                 = "/"

  tags = {
    Environment                                   = "${var.env}"
    Group                                         = "${var.env}-shared"
    "alpha.eksctl.io/cluster-name"                = "zde-${var.env}-eks"
    "alpha.eksctl.io/eksctl-version"              = "0.40.0-rc.0"
    "alpha.eksctl.io/iamserviceaccount-name"      = "cert-manager/cert-manager"
    "eksctl.cluster.k8s.io/v1alpha1/cluster-name" = "zde-${var.env}-eks"
  }

  tags_all = {
    Environment                                   = "${var.env}"
    Group                                         = "${var.env}-shared"
    "alpha.eksctl.io/cluster-name"                = "zde-${var.env}-eks"
    "alpha.eksctl.io/eksctl-version"              = "0.40.0-rc.0"
    "alpha.eksctl.io/iamserviceaccount-name"      = "cert-manager/cert-manager"
    "eksctl.cluster.k8s.io/v1alpha1/cluster-name" = "zde-${var.env}-eks"
  }
}
