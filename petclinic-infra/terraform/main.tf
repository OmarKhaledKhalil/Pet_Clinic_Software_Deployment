# provider "aws" {
#   region = var.aws_region
# }

# resource "aws_vpc" "main" {
#   cidr_block = var.vpc_cidr_block

#   tags = merge(
#     var.common_tags,
#     {
#       Name = "main-vpc ${var.name_suffix}"
#     }
#   )
# }

# resource "aws_subnet" "main" {
#   vpc_id            = aws_vpc.main.id
#   cidr_block        = var.subnet_cidr_block
#   availability_zone = var.availability_zone

#   tags = merge(
#     var.common_tags,
#     {
#       Name = "main-subnet ${var.name_suffix}"
#     }
#   )
# }

# resource "aws_security_group" "k8s_sg" {
#   name        = "k8s-sg"
#   description = "Allow SSH and Kubernetes ports"
#   vpc_id      = aws_vpc.main.id

#   ingress {
#     from_port   = var.ssh_port
#     to_port     = var.ssh_port
#     protocol    = "tcp"
#     cidr_blocks = ["${var.ci_host_ip}/32"]
#   }

#   ingress {
#     from_port   = var.k8s_api_port
#     to_port     = var.k8s_api_port
#     protocol    = "tcp"
#     cidr_blocks = ["${var.ci_host_ip}/32"]
#   }

#   ingress {
#     from_port   = var.ssh_port
#     to_port     = var.ssh_port
#     protocol    = "tcp"
#     cidr_blocks = [var.subnet_cidr_block]
#   }

#   egress {
#     from_port   = var.egress_from_port
#     to_port     = var.egress_to_port
#     protocol    = var.egress_protocol
#     cidr_blocks = var.egress_cidr_blocks
#   }

#   tags = merge(
#     var.common_tags,
#     {
#       Name = "k8s-security-group ${var.name_suffix}"
#     }
#   )
# }

# resource "aws_instance" "bastion" {
#   ami                         = var.ami_id
#   instance_type               = var.bastion_instance_type
#   key_name                    = var.key_pair
#   subnet_id                   = aws_subnet.main.id
#   vpc_security_group_ids      = [aws_security_group.k8s_sg.id]
#   associate_public_ip_address = true

#   tags = merge(
#     var.common_tags,
#     {
#       Name = "bastion-host ${var.name_suffix}"
#       Role = "bastion"
#     }
#   )
# }

# resource "aws_instance" "master" {
#   ami                         = var.ami_id
#   instance_type               = var.master_instance_type
#   key_name                    = var.key_pair
#   subnet_id                   = aws_subnet.main.id
#   vpc_security_group_ids      = [aws_security_group.k8s_sg.id]
#   associate_public_ip_address = false

#   tags = merge(
#     var.common_tags,
#     {
#       Name = "k8s-master ${var.name_suffix}"
#       Role = "master"
#     }
#   )
# }

# resource "aws_instance" "worker" {
#   ami                         = var.ami_id
#   instance_type               = var.worker_instance_type
#   key_name                    = var.key_pair
#   subnet_id                   = aws_subnet.main.id
#   vpc_security_group_ids      = [aws_security_group.k8s_sg.id]
#   associate_public_ip_address = false

#   tags = merge(
#     var.common_tags,
#     {
#       Name = "k8s-worker ${var.name_suffix}"
#       Role = "worker"
#     }
#   )
# }
