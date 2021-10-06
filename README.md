# terraform_eks


terraform import aws_eks_cluster.eks_cluster zde-devopssampleenv-eks
terraform import aws_iam_role.eks-addon-iamserviceacco-Role eksctl-zde-devopssampleenv-eks-addon-iamserv-Role1-EABIEE9W76VO
terraform import aws_iam_role.eks-nodegroup-NodeInstanceRole eksctl-zde-devopssampleenv-eks-no-NodeInstanceRole-9KESDCT35GR5
terraform import aws_eks_node_group.my_node_group zde-devopssampleenv-eks:zde-services
terraform import aws_iam_role.zde-eks-alb-role  zde-devopssampleenv-eks-alb-role
terraform import aws_iam_role.zde-eks-autoscaller-role zde-devopssampleenv-eks-autoscaller-role 
terraform import aws_iam_role.zde-eks-cloudwatch-role zde-devopssampleenv-eks-cloudwatch-role
terraform import aws_iam_role.zde-eks-dns-role zde-devopssampleenv-eks-dns-role
terraform import aws_iam_role.zde-eks-tls-role zde-devopssampleenv-eks-tls-role

terraform import aws_security_group.EKSControlPlane sg-0c8ab295173f79c5f
terraform import aws_security_group.ClusterSharedNodeSecurityGroup sg-04ef0d62384f65540
