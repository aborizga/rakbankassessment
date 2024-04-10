resource "aws_eks_cluster" "rakbank_cluster" {
  name     = var.cluster_name
  role_arn = aws_iam_role.rakbank.arn

  vpc_config {
    subnet_ids              = var.aws_public_subnet
    endpoint_public_access  = var.endpoint_public_access
    endpoint_private_access = var.endpoint_private_access
    public_access_cidrs     = var.public_access_cidrs
    security_group_ids      = [aws_security_group.node_group_one.id]
  }

  depends_on = [
    aws_iam_role_policy_attachment.rakbank-AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.rakbank-AmazonEKSVPCResourceController,
  ]
}

resource "aws_eks_node_group" "rakbank-ng" {
  cluster_name    = aws_eks_cluster.rakbank_cluster.name
  node_group_name = var.node_group_name
  node_role_arn   = aws_iam_role.rakbank.arn
  subnet_ids      = var.aws_public_subnet
  instance_types  = var.instance_types

  remote_access {
    source_security_group_ids = [aws_security_group.node_group_one.id]
    ec2_ssh_key               = var.key_pair
  }

  scaling_config {
    desired_size = var.scaling_desired_size
    max_size     = var.scaling_max_size
    min_size     = var.scaling_min_size
  }

  depends_on = [
    aws_iam_role_policy_attachment.rakbank2-AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.rakbank-AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.rakbank-AmazonEC2ContainerRegistryReadOnly,
  ]
}

resource "aws_security_group" "node_group_one" {
  name_prefix = "node_group_one"
  vpc_id      = var.vpc_id

  ingress {
    from_port = 80
    to_port   = 80
    protocol  = "tcp"

    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_iam_role" "rakbank" {
  name = "eks-cluster-rakbank"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": ["eks.amazonaws.com", "ec2.amazonaws.com"]
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}
resource "aws_key_pair" "deployer" {
  key_name = "deployer-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCMAhNZdsDKiT2IuG2JL3iX4mTGbAQMwL+15oXQTdBrAxX2pwA23QnHqt3456Z/T3r7ZNVWHkCE68ahSlZmKlMkoJDani0qHMTS3uFZZV17sk1qUjIKNKkptRqU4Z+X0g+w1ViScjAk8LywATBo7nPnRmeCuuXX6NveqDD83ymDQAWNUFw1z8j9XLt20I3YGh0SiHFjMVKhR/KuD4FCkpr9tUN9Y1uZXp3LsrS6LCXw2HfSDDOc0GA/2IKc7B09s+aJYFEFXrfAh6BrpIKIQw/D0lbLrskv96SuJCuM0dgUYKgS3MR6HNkyXTG/pMU5OqlOkwq1Nwp9Us3C34b4DON1 rsa-key-20240329"
  
}

resource "aws_iam_role_policy_attachment" "rakbank-AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.rakbank.name
}

resource "aws_iam_role_policy_attachment" "rakbank-AmazonEKSVPCResourceController" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  role       = aws_iam_role.rakbank.name
}

resource "aws_iam_role" "rakbank2" {
  name = "eks-node-group-rakbank2"

  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
}

resource "aws_iam_role_policy_attachment" "rakbank2-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.rakbank2.name
}

resource "aws_iam_role_policy_attachment" "rakbank-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.rakbank2.name
}

resource "aws_iam_role_policy_attachment" "rakbank-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.rakbank2.name
}
