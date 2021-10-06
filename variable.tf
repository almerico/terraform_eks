variable "env" {
}

variable "region" {
}

variable "vpc_cidr_classB" {
}

variable "public_access_cidrs" {
  default = []
}

variable "domain_name" {
}

variable "key_name" {
}

variable "db_instance_class" {
}

variable "db_allocated_storage" {
}

variable "db_user" {
}

variable "db_password" {
}

variable "eks_cluster_name_suffix" {
}

variable "eks_node_instance_type" {
  default = "t3a.large"
}

variable "eks_node_min_size" {
}

variable "eks_node_max_size" {
}

variable "eks_node_desired_capacity" {
}

variable "tls_certificate_owner_email" {
}

variable "zde_version" {
}

variable "create_dns_zone" {
}

variable "create_ssh_key" {
}

variable "create_zone_policy" {
  default = true
}

variable "eks-addon-iamserviceacco-Role" {
  default = "eksctl-zde-devopssampleenv-eks-addon-iamserv-Role1-EABIEE9W76VO"
}
variable "eks-cluster-ServiceRole" {
  default = "eksctl-zde-devopssampleenv-eks-cluster-ServiceRole-16VP3USFZXFNL"
}
variable "eks-no-NodeInstanceRole" {
  default = "eksctl-zde-devopssampleenv-eks-no-NodeInstanceRole-9KESDCT35GR5"
}
variable "EKS_control_palne_sg_name" {
  default = "eks-cluster-sg-zde-devopssampleenv-eks-1116375788"
}
variable "cluster_shared_node_security_group_name" {
  default = "eksctl-zde-devopssampleenv-eks-cluster-ClusterSharedNodeSecurityGroup-UEM1LV1XK7O9"
}