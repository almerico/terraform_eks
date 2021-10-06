data "aws_caller_identity" "current" {}

resource "aws_eks_cluster" "cluster" {
  kubernetes_network_config {
    service_ipv4_cidr = "172.20.0.0/16"
  }
  #   lifecycle {
  #    prevent_destroy = true
  #  }
  name     = "zde-${var.env}-eks"
  role_arn = aws_iam_role.eksctl-zde-eks-cluster-ServiceRole.arn

  tags = {
    Environment = "${var.env}"
    Group       = "${var.env}-shared"
  }

  tags_all = {
    Environment                      = "${var.env}"
    Group                            = "${var.env}-shared"
    "alpha.eksctl.io/eksctl-version" = "0.40.0-rc.0"
  }

  version = "1.19"

  vpc_config {
    endpoint_private_access = "true"
    endpoint_public_access  = "true"
    public_access_cidrs     = var.public_access_cidrs
    security_group_ids      = [module.zde-eks.aws_security_group_cluster]
    subnet_ids              = module.zde-eks.private_subnets
  }
}
resource "aws_security_group" "ClusterSharedNodeSecurityGroup" {
  description = "Communication between all nodes in the cluster"
  egress = [
    {
      cidr_blocks = [
        "0.0.0.0/0",
      ]
      description      = ""
      from_port        = 0
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      protocol         = "-1"
      security_groups  = []
      self             = false
      to_port          = 0
    },
  ]
  ingress = [
    {
      cidr_blocks      = []
      description      = "Allow managed and unmanaged nodes to communicate with each other (all ports)"
      from_port        = 0
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      protocol         = "-1"
      security_groups = [
        "${aws_security_group.EKSControlPlane.id}",
      ]
      self    = false
      to_port = 0
    },
    {
      cidr_blocks      = []
      description      = "Allow nodes to communicate with each other (all ports)"
      from_port        = 0
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      protocol         = "-1"
      security_groups  = []
      self             = true
      to_port          = 0
    },
  ]
  name = var.cluster_shared_node_security_group_name
  tags = {
    "Environment"                                 = "${var.env}"
    "Group"                                       = "${var.env}-shared"
    "Name"                                        = "eksctl-zde-${var.env}-eks-cluster/ClusterSharedNodeSecurityGroup"
    "alpha.eksctl.io/cluster-name"                = "zde-${var.env}-eks"
    "alpha.eksctl.io/eksctl-version"              = "0.40.0-rc.0"
    "eksctl.cluster.k8s.io/v1alpha1/cluster-name" = "zde-${var.env}-eks"
  }
  tags_all = {
    "Environment"                                 = "${var.env}"
    "Group"                                       = "${var.env}-shared"
    "Name"                                        = "eksctl-zde-${var.env}-eks-cluster/ClusterSharedNodeSecurityGroup"
    "alpha.eksctl.io/cluster-name"                = "zde-${var.env}-eks"
    "alpha.eksctl.io/eksctl-version"              = "0.40.0-rc.0"
    "eksctl.cluster.k8s.io/v1alpha1/cluster-name" = "zde-${var.env}-eks"
  }
  vpc_id = module.zde-eks.vpc_id

  timeouts {}
}
resource "aws_security_group" "EKSControlPlane" {
  description = "EKS created security group applied to ENI that is attached to EKS Control Plane master nodes, as well as any managed workloads."
  egress = [
    {
      cidr_blocks = [
        "0.0.0.0/0",
      ]
      description      = ""
      from_port        = 0
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      protocol         = "-1"
      security_groups  = []
      self             = false
      to_port          = 0
    },
  ]


  ingress = [
    {
      cidr_blocks      = []
      description      = ""
      from_port        = 0
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      protocol         = "-1"
      security_groups  = []
      self             = true
      to_port          = 0
    }
  ]
  #         {
  #             cidr_blocks      = []
  #             description      = "Allow unmanaged nodes to communicate with control plane (all ports)"
  #             from_port        = 0
  #             ipv6_cidr_blocks = []
  #             prefix_list_ids  = []
  #             protocol         = "-1"
  #             security_groups  = [
  #                 "${aws_security_group.ClusterSharedNodeSecurityGroup}",
  #             ]
  #             self             = false
  #             to_port          = 0
  #         },
  #     ]
  name = var.EKS_control_palne_sg_name
  tags = {
    "Name"                                     = "${var.EKS_control_palne_sg_name}"
    "kubernetes.io/cluster/zde-${var.env}-eks" = "owned"
  }
  tags_all = {
    "Name"                                     = "${var.EKS_control_palne_sg_name}"
    "kubernetes.io/cluster/zde-${var.env}-eks" = "owned"
  }
  vpc_id = module.zde-eks.vpc_id

  #     timeouts {}
}
resource "aws_security_group_rule" "allow_ClusterSharedNodeSecurityGroup" {
  type              = "ingress"
  description       = "Allow unmanaged nodes to communicate with control plane (all ports)"
  from_port         = 0
  protocol          = "-1"
  security_group_id = aws_security_group.ClusterSharedNodeSecurityGroup.id
  to_port           = 0
}