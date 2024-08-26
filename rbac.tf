resource "kubernetes_cluster_role" "reader" {
  metadata {
    name = "reader"
  }

  rule {
    api_groups = ["*"]
    resources  = ["deployments", "configmaps", "pods", "secrets", "services"]
    verbs      = ["get", "list", "watch"]
  }
}




resource "kubernetes_cluster_role_binding" "reader" {
  metadata {
    name = "reader"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "reader"
  }

  subject {
    kind      = "Group"
    name      = "reader"
    api_group = "rbac.authorization.k8s.io"
  }
}

# resource "kubernetes_config_map" "aws_auth" {
#   metadata {
#     name      = "aws-auth"
#     namespace = "kube-system"
#   }

#   data = {
#     mapRoles = <<-EOT
#       - rolearn: arn:aws:iam::024848443289:role/eks-cluster-demo
#         username: eks-cluster-role
#         groups:
#           - reader
#     EOT

#     mapUsers = <<-EOT
#       - userarn: arn:aws:iam::024848443289:user/developer
#         username: developer
#         groups:
#           - reader
#     EOT
#   }
# }

resource "kubernetes_config_map" "aws-auth" {
  data = {
    mapRoles = <<-EOT
      - groups:
        - system:bootstrappers
        - system:nodes
        rolearn: arn:aws:iam::024848443289:role/eks-node-group-nodes
        username: system:node:{{EC2PrivateDNSName}}
    EOT

    mapUsers = <<-EOT
      - userarn: arn:aws:iam::024848443289:user/developer
        username: developer
        groups:
          - reader
    EOT

  }
  metadata {
    name      = "aws-auth"
    namespace = "kube-system"
  }
}