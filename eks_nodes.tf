resource "aws_eks_node_group" "my_node_group" {
  ami_type     = "AL2_x86_64"
  cluster_name = "zde-${var.env}-eks"

  labels = {
    "alpha.eksctl.io/cluster-name"   = "zde-${var.env}-eks"
    "alpha.eksctl.io/nodegroup-name" = "zde-services"
    "role"                           = "zde"
  }
  node_group_name = "zde-services"
  node_role_arn   = aws_iam_role.eks-nodegroup-NodeInstanceRole.arn
  subnet_ids      = module.zde-eks.private_subnets
  tags = {
    "Environment"                                 = "${var.env}"
    "Group"                                       = "${var.env}-shared"
    "alpha.eksctl.io/cluster-name"                = "zde-${var.env}-eks"
    "alpha.eksctl.io/eksctl-version"              = "0.40.0-rc.0"
    "alpha.eksctl.io/nodegroup-name"              = "zde-services"
    "alpha.eksctl.io/nodegroup-type"              = "managed"
    "eksctl.cluster.k8s.io/v1alpha1/cluster-name" = "zde-${var.env}-eks"
  }
  tags_all = {
    "Environment"                                 = "${var.env}"
    "Group"                                       = "${var.env}-shared"
    "alpha.eksctl.io/cluster-name"                = "zde-${var.env}-eks"
    "alpha.eksctl.io/eksctl-version"              = "0.40.0-rc.0"
    "alpha.eksctl.io/nodegroup-name"              = "zde-services"
    "alpha.eksctl.io/nodegroup-type"              = "managed"
    "eksctl.cluster.k8s.io/v1alpha1/cluster-name" = "zde-${var.env}-eks"
  }
  version = "1.19"

  launch_template {

    name = "zde-${var.env}-cluster-lt"
    #TODO needes to be updated to 1, 3 here  beacuse increased with every install
    version = "3"

  }

  scaling_config {
    desired_size = var.eks_node_desired_capacity
    max_size     = var.eks_node_max_size
    min_size     = var.eks_node_min_size
  }
}
