provider "aws" {
  region = var.aws_region
}

# VPC
resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr_block
  tags = merge(var.common_tags, { Name = "vpc-${var.name_suffix}" })
}

# IGW and NAT
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id
  tags = { Name = "igw-${var.name_suffix}" }
}
resource "aws_eip" "nat" {}
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public.id
  tags = { Name = "nat-gateway-${var.name_suffix}" }
}

# Subnets
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidr_block
  availability_zone       = var.availability_zone
  map_public_ip_on_launch = true
  tags = merge(var.common_tags, { Name = "public-subnet-${var.name_suffix}" })
}
resource "aws_subnet" "private" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.private_subnet_cidr_block
  availability_zone       = var.availability_zone
  map_public_ip_on_launch = false
  tags = merge(var.common_tags, { Name = "private-subnet-${var.name_suffix}" })
}

# Route tables
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
  tags = { Name = "public-rt-${var.name_suffix}" }
}
resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public_rt.id
}
resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }
  tags = { Name = "private-rt-${var.name_suffix}" }
}
resource "aws_route_table_association" "private_assoc" {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.private_rt.id
}

# BASTION Security Group: SSH from Jenkins public IP only
resource "aws_security_group" "bastion_sg" {
  name        = "bastion-sg-${var.name_suffix}"
  description = "Allow SSH from Jenkins only."
  vpc_id      = aws_vpc.main.id
  ingress {
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
  tags = merge(var.common_tags, { Name = "bastion-sg-${var.name_suffix}" })
}

# PRIVATE Security Group: SSH only from Bastion. Outbound allowed
resource "aws_security_group" "private_sg" {
  name        = "private-sg-${var.name_suffix}"
  description = "Internal SSH from Bastion only."
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "SSH from Bastion in public subnet"
    from_port   = var.ssh_port
    to_port     = var.ssh_port
    protocol    = "tcp"
    cidr_blocks = [var.public_subnet_cidr_block] # Only allows from Bastion in the public subnet
  }

ingress {
    description      = "Allow Kubernetes API server traffic"
    from_port        = var.k8s_api_port
    to_port          = var.k8s_api_port
    protocol         = "tcp"
    cidr_blocks      = [var.private_subnet_cidr_block] # Allow access from private subnet (workers & master)
  }

  egress {
    description = "Allow all egress"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = merge(var.common_tags, { Name = "private-sg-${var.name_suffix}" })
}

# BASTION Host
resource "aws_instance" "bastion" {
  ami                         = var.ami_id
  instance_type               = var.bastion_instance_type
  subnet_id                   = aws_subnet.public.id
  key_name                    = var.key_pair
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.bastion_sg.id]
  tags = merge(var.common_tags, { Name = "bastion-${var.name_suffix}" })
}

# MASTER Host (private subnet, only reachable from Bastion)
resource "aws_instance" "master" {
  ami           = var.ami_id
  instance_type = var.master_instance_type
  subnet_id     = aws_subnet.private.id
  key_name      = var.key_pair
  vpc_security_group_ids = [aws_security_group.private_sg.id]

  tags = merge(var.common_tags, { Name = "master-${var.name_suffix}" })
}

# WORKER Hosts (private subnet)
resource "aws_instance" "worker" {
  count         = var.worker_count
  ami           = var.ami_id
  instance_type = var.worker_instance_type
  subnet_id     = aws_subnet.private.id
  key_name      = var.key_pair
  vpc_security_group_ids = [aws_security_group.private_sg.id]

  tags = merge(var.common_tags, { Name = "worker${count.index + 1}-${var.name_suffix}" })
}
