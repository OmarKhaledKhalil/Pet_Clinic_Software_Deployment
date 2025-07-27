provider "aws" {
  region = var.aws_region
}

resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr_block

  tags = merge(
    var.common_tags,
    {
      Name = "main-vpc ${var.name_suffix}"
    }
  )
}

resource "aws_internet_gateway" "main_igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "main-igw-${var.name_suffix}"
  }
}

resource "aws_subnet" "main" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.subnet_cidr_block
  availability_zone = var.availability_zone

  tags = merge(
    var.common_tags,
    {
      Name = "main-subnet ${var.name_suffix}"
    }
  )
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main_igw.id
  }

  tags = {
    Name = "public-rt-${var.name_suffix}"
  }
}

resource "aws_route_table_association" "main_assoc" {
  subnet_id      = aws_subnet.main.id
  route_table_id = aws_route_table.public_rt.id
}

# Bastion Security Group - SSH only from Jenkins host public IP
resource "aws_security_group" "bastion_sg" {
  name        = "bastion-sg-${var.name_suffix}"
  description = "Allow SSH to bastion from Jenkins"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "SSH from Jenkins host ip"
    from_port   = var.ssh_port
    to_port     = var.ssh_port
    protocol    = "tcp"
    cidr_blocks = ["${var.jenkins_host_ip}/32"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    var.common_tags,
    {
      Name = "bastion-sg ${var.name_suffix}"
    }
  )
}

# K8s Security Group - SSH only from Bastion SG (secure and works in single subnet)
resource "aws_security_group" "k8s_sg" {
  name        = "k8s-sg-${var.name_suffix}"
  description = "Allow SSH from Bastion & K8s API from CI/CD"
  vpc_id      = aws_vpc.main.id

  # SSH from Bastion host ONLY (by security group)
  ingress {
    description     = "SSH from Bastion SG"
    from_port       = var.ssh_port
    to_port         = var.ssh_port
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion_sg.id]
  }

  # Kubernetes API from CI/CD server (Jenkins, etc)
  ingress {
    description = "K8s API from CI/CD"
    from_port   = var.k8s_api_port
    to_port     = var.k8s_api_port
    protocol    = "tcp"
    cidr_blocks = ["${var.ci_host_ip}/32"]
  }

  egress {
    from_port   = var.egress_from_port
    to_port     = var.egress_to_port
    protocol    = var.egress_protocol
    cidr_blocks = var.egress_cidr_blocks
  }

  tags = merge(
    var.common_tags,
    {
      Name = "k8s-security-group ${var.name_suffix}"
    }
  )
}

resource "aws_instance" "bastion" {
  ami                         = var.ami_id
  instance_type               = var.bastion_instance_type
  key_name                    = var.key_pair
  subnet_id                   = aws_subnet.main.id
  vpc_security_group_ids      = [aws_security_group.bastion_sg.id]
  associate_public_ip_address = true

  tags = merge(
    var.common_tags,
    {
      Name = "bastion-host ${var.name_suffix}",
      Role = "bastion"
    }
  )
}

resource "aws_instance" "master" {
  ami                         = var.ami_id
  instance_type               = var.master_instance_type
  key_name                    = var.key_pair
  subnet_id                   = aws_subnet.main.id
  vpc_security_group_ids      = [aws_security_group.k8s_sg.id]
  associate_public_ip_address = false

  tags = merge(
    var.common_tags,
    {
      Name = "k8s-master ${var.name_suffix}",
      Role = "master"
    }
  )
}

resource "aws_instance" "worker" {
  count                       = var.worker_count
  ami                         = var.ami_id
  instance_type               = var.worker_instance_type
  key_name                    = var.key_pair
  subnet_id                   = aws_subnet.main.id
  vpc_security_group_ids      = [aws_security_group.k8s_sg.id]
  associate_public_ip_address = false

  tags = merge(
    var.common_tags,
    {
      Name = "k8s-worker-${count.index + 1} ${var.name_suffix}",
      Role = "worker"
    }
  )
}
