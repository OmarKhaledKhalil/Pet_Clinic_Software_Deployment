provider "aws" {
  region = var.aws_region
}

# VPC
resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr_block

  tags = merge(
    var.common_tags,
    {
      Name = "vpc-${var.name_suffix}"
    }
  )
}

# Internet Gateway
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "igw-${var.name_suffix}"
  }
}

# Public Subnet (for bastion & NAT)
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidr_block
  availability_zone       = var.availability_zone
  map_public_ip_on_launch = true

  tags = merge(
    var.common_tags,
    {
      Name = "public-subnet-${var.name_suffix}"
    }
  )
}

# Private Subnet (for master/workers)
resource "aws_subnet" "private" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.private_subnet_cidr_block
  availability_zone       = var.availability_zone
  map_public_ip_on_launch = false

  tags = merge(
    var.common_tags,
    {
      Name = "private-subnet-${var.name_suffix}"
    }
  )
}

# Elastic IP for NAT
resource "aws_eip" "nat" {
  vpc = true
}

# NAT Gateway in public subnet
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public.id

  tags = {
    Name = "nat-gateway-${var.name_suffix}"
  }
}

# Public Route Table
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "public-rt-${var.name_suffix}"
  }
}

resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public_rt.id
}

# Private Route Table
resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }

  tags = {
    Name = "private-rt-${var.name_suffix}"
  }
}

resource "aws_route_table_association" "private_assoc" {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.private_rt.id
}

# Bastion Instance (public subnet)
resource "aws_instance" "bastion" {
  ami                         = var.ami_id
  instance_type               = var.bastion_instance_type
  subnet_id                   = aws_subnet.public.id
  key_name                    = var.key_pair
  associate_public_ip_address = true

  tags = merge(
    var.common_tags,
    {
      Name = "bastion-${var.name_suffix}"
    }
  )
}

# Master Instance (private subnet)
resource "aws_instance" "master" {
  ami           = var.ami_id
  instance_type = var.master_instance_type
  subnet_id     = aws_subnet.private.id
  key_name      = var.key_pair

  tags = merge(
    var.common_tags,
    {
      Name = "master-${var.name_suffix}"
    }
  )
}

# Worker Instances (private subnet, dynamic count)
resource "aws_instance" "worker" {
  count         = var.worker_count
  ami           = var.ami_id
  instance_type = var.worker_instance_type
  subnet_id     = aws_subnet.private.id
  key_name      = var.key_pair

  tags = merge(
    var.common_tags,
    {
      Name = "worker${count.index + 1}-${var.name_suffix}"
    }
  )
}
