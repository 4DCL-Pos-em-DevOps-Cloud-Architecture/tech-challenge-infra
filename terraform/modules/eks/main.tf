module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 21.0"

  name               = var.cluster_name
  kubernetes_version = var.cluster_version

  create_iam_role = false
  iam_role_arn    = var.lab_role_arn

  vpc_id     = var.vpc_id
  subnet_ids = var.private_subnet_ids

  enable_cluster_creator_admin_permissions = true
  endpoint_private_access                  = true

  compute_config = {
    enabled = false
  }

  addons = {
    coredns                = {}
    kube-proxy             = {}
    eks-pod-identity-agent = {}
    vpc-cni                = {}
  }

  eks_managed_node_groups = {
    general = {
      name           = "${var.cluster_name}-nodes"
      ami_type       = "AL2023_x86_64_STANDARD"
      instance_types = ["t3.medium"]

      min_size     = 1
      max_size     = 2
      desired_size = 1

      subnet_ids = var.private_subnet_ids

      # Também utiliza a LabRole para os nodes
      create_iam_role = false
      iam_role_arn    = var.lab_role_arn
    }
  }

  tags = var.tags
}
