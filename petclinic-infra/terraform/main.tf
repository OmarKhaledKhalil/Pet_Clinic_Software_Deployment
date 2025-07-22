provider "aws" {
  region = var.aws_region  # Set the AWS region based on the provided variable.
}

resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr_block  # Define the IP range for the VPC.

  tags = merge(
    var.common_tags,  # Include common tags for resource identification.
    {
      Name = "main-vpc ${var.name_suffix}"  # Assign a unique name to the VPC.
    }
  )
}

resource "aws_subnet" "main" {
  vpc_id            = aws_vpc.main.id  # Attach the subnet to the main VPC.
  cidr_block        = var.subnet_cidr_block  # Define the IP range for the subnet.
  availability_zone = var.availability_zone  # Specify availability zone.

  tags = merge(
    var.common_tags,
    {
      Name = "main-subnet ${var.name_suffix}"  # Name the subnet for identification.
    }
  )
}

resource "aws_security_group" "k8s_sg" {
  name        = "k8s-sg"  # Name the Security Group.
  description = "Allow SSH and Kubernetes ports"
  vpc_id      = aws_vpc.main.id  # Associate with the main VPC.

  ingress {
    from_port   = var.ssh_port  # Allow SSH on specified port.
    to_port     = var.ssh_port
    protocol    = "tcp"
    cidr_blocks = ["${var.ci_host_ip}/32"]  # Restrict SSH to CI/CD IP.
  }

  ingress {
    from_port   = var.k8s_api_port  # Expose Kubernetes API port.
    to_port     = var.k8s_api_port
    protocol    = "tcp"
    cidr_blocks = ["${var.ci_host_ip}/32"]  # Restrict API access to CI/CD IP.
  }

  ingress {
    from_port   = var.ssh_port
    to_port     = var.ssh_port
    protocol    = "tcp"
    cidr_blocks = [var.subnet_cidr_block]  # Allow internal SSH within subnet.
  }

  egress {
    from_port   = var.egress_from_port  # Allow outbound traffic.
    to_port     = var.egress_to_port
    protocol    = var.egress_protocol
    cidr_blocks = var.egress_cidr_blocks
  }

  tags = merge(
    var.common_tags,
    {
      Name = "k8s-security-group ${var.name_suffix}"  # Name the security group.
    }
  )
}

resource "aws_instance" "bastion" {
  ami                         = var.ami_id  # AMI for EC2 instance.
  instance_type               = var.bastion_instance_type  # Define instance type.
  key_name                    = var.key_pair  # SSH key for access.
  subnet_id                   = aws_subnet.main.id  # Locate in the main subnet.
  vpc_security_group_ids      = [aws_security_group.k8s_sg.id]  # Attach security group.
  associate_public_ip_address = true  # Provide a public IP for access.

  tags = merge(
    var.common_tags,
    {
      Name = "bastion-host ${var.name_suffix}",  # Name for the bastion host.
      Role = "bastion"  # Define the role for clarity.
    }
  )
}

resource "aws_instance" "master" {
  ami                         = var.ami_id
  instance_type               = var.master_instance_type
  key_name                    = var.key_pair
  subnet_id                   = aws_subnet.main.id
  vpc_security_group_ids      = [aws_security_group.k8s_sg.id]
  associate_public_ip_address = false  # No public IP for internal master node.

  tags = merge(
    var.common_tags,
    {
      Name = "k8s-master ${var.name_suffix}",  # Name for the master node.
      Role = "master"  # Define the role.
    }
  )
}

resource "aws_instance" "worker" {
  count                       = var.worker_count  # Number of worker nodes.
  ami                         = var.ami_id
  instance_type               = var.worker_instance_type
  key_name                    = var.key_pair
  subnet_id                   = aws_subnet.main.id
  vpc_security_group_ids      = [aws_security_group.k8s_sg.id]
  associate_public_ip_address = false  # No public IP for worker nodes.

  tags = merge(
    var.common_tags,
    {
      Name = "k8s-worker-${count.index + 1} ${var.name_suffix}",  # Unique name for each worker.
      Role = "worker"  # Define the role.
    }
  )
}