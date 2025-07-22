# provider "aws" {
#   region = var.aws_region                # Specifies the AWS region to deploy resources into, e.g., "us-east-1"
# }

# resource "aws_vpc" "main" {
#   cidr_block = var.vpc_cidr_block        # CIDR block for the custom VPC, e.g., "10.0.0.0/16"

#   tags = merge(
#     var.common_tags,                     # Common tags like Owner1, Owner2, etc.
#     {
#       Name = "main-vpc ${var.name_suffix}"  # Adds a custom name to the VPC using a suffix (e.g., "-GroupB")
#     }
#   )
# }

# resource "aws_subnet" "main" {
#   vpc_id            = aws_vpc.main.id       # Attaches this subnet to the above VPC
#   cidr_block        = var.subnet_cidr_block # CIDR block for the subnet, e.g., "10.0.1.0/24"
#   availability_zone = var.availability_zone # Specifies AZ, e.g., "us-east-1a"

#   tags = merge(
#     var.common_tags,
#     {
#       Name = "main-subnet ${var.name_suffix}"  # Custom name for easier identification
#     }
#   )
# }

# resource "aws_security_group" "k8s_sg" {
#   name        = "k8s-sg"                     # Name of the Security Group
#   description = "Allow SSH and Kubernetes ports"
#   vpc_id      = aws_vpc.main.id              # Associate this SG with the VPC

#   ingress {
#     from_port   = var.ssh_port               # Typically port 22 for SSH
#     to_port     = var.ssh_port
#     protocol    = "tcp"
#     cidr_blocks = ["${var.ci_host_ip}/32"]   # Allow SSH only from CI machine (Jenkins host)
#   }

#   ingress {
#     from_port   = var.k8s_api_port           # Typically port 6443 for Kubernetes API
#     to_port     = var.k8s_api_port
#     protocol    = "tcp"
#     cidr_blocks = ["${var.ci_host_ip}/32"]   # Allow K8s API access only from CI machine
#   }

#   ingress {
#     from_port   = var.ssh_port
#     to_port     = var.ssh_port
#     protocol    = "tcp"
#     cidr_blocks = [var.subnet_cidr_block]    # Internal SSH access within subnet (e.g., bastion to master)
#   }

#   egress {
#     from_port   = var.egress_from_port       # Typically 0
#     to_port     = var.egress_to_port         # Typically 0
#     protocol    = var.egress_protocol        # "tcp", "udp", or "-1" for all
#     cidr_blocks = var.egress_cidr_blocks     # Typically ["0.0.0.0/0"] to allow all outbound traffic
#   }

#   tags = merge(
#     var.common_tags,
#     {
#       Name = "k8s-security-group ${var.name_suffix}"
#     }
#   )
# }

# resource "aws_instance" "bastion" {
#   ami                         = var.ami_id                  # AMI ID for EC2 (e.g., Amazon Linux 2)
#   instance_type               = var.bastion_instance_type   # Instance type (e.g., t2.micro)
#   key_name                    = var.key_pair                # SSH key for login
#   subnet_id                   = aws_subnet.main.id
#   vpc_security_group_ids      = [aws_security_group.k8s_sg.id]
#   associate_public_ip_address = true                        # Makes this instance publicly accessible (bastion)

#   tags = merge(
#     var.common_tags,
#     {
#       Name = "bastion-host ${var.name_suffix}",             # Helpful label
#       Role = "bastion"                                      # For identification and automation
#     }
#   )
# }

# resource "aws_instance" "master" {
#   ami                         = var.ami_id
#   instance_type               = var.master_instance_type
#   key_name                    = var.key_pair
#   subnet_id                   = aws_subnet.main.id
#   vpc_security_group_ids      = [aws_security_group.k8s_sg.id]
#   associate_public_ip_address = false                       # Internal only (access via bastion)

#   tags = merge(
#     var.common_tags,
#     {
#       Name = "k8s-master ${var.name_suffix}",
#       Role = "master"
#     }
#   )
# }

# resource "aws_instance" "worker" {
#   count                       = var.worker_count            # Deploy multiple worker nodes based on variable
#   ami                         = var.ami_id
#   instance_type               = var.worker_instance_type
#   key_name                    = var.key_pair
#   subnet_id                   = aws_subnet.main.id
#   vpc_security_group_ids      = [aws_security_group.k8s_sg.id]
#   associate_public_ip_address = false

#   tags = merge(
#     var.common_tags,
#     {
#       Name = "k8s-worker-${count.index + 1} ${var.name_suffix}", # Auto-numbered workers
#       Role = "worker"
#     }
#   )
# }
