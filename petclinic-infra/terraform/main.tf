terraform {
  backend "s3" {
    bucket  = "petclinic-terraform-state-redteam"
    key     = "petclinic-infra/terraform.tfstate"
    region  = "us-east-1"
    encrypt = true
  }
}

provider "aws" {
  region = var.aws_region
}

# ------------------------------
# VPC
# ------------------------------
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags                 = merge(var.common_tags, { Name = "vpc-${var.name_suffix}" })
}

# ------------------------------
# IGW and NAT
# ------------------------------
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id
  tags   = { Name = "igw-${var.name_suffix}" }
}

resource "aws_eip" "nat" {}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public.id
  tags          = { Name = "nat-gateway-${var.name_suffix}" }
}

# ------------------------------
# Subnets
# ------------------------------
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidr_block
  availability_zone       = var.availability_zone
  map_public_ip_on_launch = true
  tags                    = merge(var.common_tags, { Name = "public-subnet-${var.name_suffix}" })
}

resource "aws_subnet" "public_2" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidr_block_2
  availability_zone       = var.availability_zone_2
  map_public_ip_on_launch = true
  tags                    = merge(var.common_tags, { Name = "public-subnet-2-${var.name_suffix}" })
}

resource "aws_subnet" "private" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.private_subnet_cidr_block
  availability_zone       = var.availability_zone
  map_public_ip_on_launch = false
  tags                    = merge(var.common_tags, { Name = "private-subnet-${var.name_suffix}" })
}

# ------------------------------
# Route tables
# ------------------------------
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = var.default_cidr_block
    gateway_id = aws_internet_gateway.gw.id
  }
  tags = { Name = "public-rt-${var.name_suffix}" }
}

resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "public_assoc_2" {
  subnet_id      = aws_subnet.public_2.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block     = var.default_cidr_block
    nat_gateway_id = aws_nat_gateway.nat.id
  }
  tags = { Name = "private-rt-${var.name_suffix}" }
}

resource "aws_route_table_association" "private_assoc" {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.private_rt.id
}

# ------------------------------
# Security Groups
# ------------------------------
resource "aws_security_group" "bastion_sg" {
  name        = "bastion-sg-${var.name_suffix}"
  description = "Allow SSH from specified external IP only."
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "SSH from external IP"
    from_port   = var.ssh_port
    to_port     = var.ssh_port
    protocol    = "tcp"
    cidr_blocks = ["${var.external_access_ip}/32"]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = var.egress_from_port
    to_port     = var.egress_to_port
    protocol    = var.egress_protocol
    cidr_blocks = var.egress_cidr_blocks
  }

  tags = merge(var.common_tags, { Name = "bastion-sg-${var.name_suffix}" })
}

resource "aws_security_group" "private_sg" {
  name        = "private-sg-${var.name_suffix}"
  description = "Security group for Kubernetes nodes - allows all traffic from bastion and within private subnet."
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "All traffic from bastion security group"
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    security_groups = [aws_security_group.bastion_sg.id]
  }

  ingress {
    description = "All traffic within private security group"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    self        = true
  }

  ingress {
    description     = "Allow all traffic from ALB"
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    security_groups = [aws_security_group.alb_sg.id]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = var.egress_from_port
    to_port     = var.egress_to_port
    protocol    = var.egress_protocol
    cidr_blocks = var.egress_cidr_blocks
  }

  tags = merge(var.common_tags, { Name = "private-sg-${var.name_suffix}" })
}

resource "aws_security_group" "alb_sg" {
  name        = "alb-sg-${var.name_suffix}"
  description = "Allow HTTP/HTTPS access to ALB"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "Allow HTTP"
    from_port   = var.alb_http_port
    to_port     = var.alb_http_port
    protocol    = "tcp"
    cidr_blocks = [var.default_cidr_block]
  }

  ingress {
    description = "Allow HTTPS"
    from_port   = var.alb_https_port
    to_port     = var.alb_https_port
    protocol    = "tcp"
    cidr_blocks = [var.default_cidr_block]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.default_cidr_block]
  }

  tags = merge(var.common_tags, { Name = "alb-sg-${var.name_suffix}" })
}

# ------------------------------
# ALB + Path Routing
# ------------------------------
resource "aws_lb" "app_alb" {
  name               = "app-alb-${var.name_suffix}"
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = [aws_subnet.public.id, aws_subnet.public_2.id]
  tags               = merge(var.common_tags, { Name = "app-alb-${var.name_suffix}" })
}

# Frontend TG
resource "aws_lb_target_group" "frontend_tg" {
  name     = "frontend-tg-${var.name_suffix}"
  port     = var.frontend_tg_port
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id
  health_check {
    path                = var.alb_health_check_path
    interval            = var.alb_health_check_interval
    timeout             = var.alb_health_check_timeout
    healthy_threshold   = var.alb_health_check_healthy_threshold
    unhealthy_threshold = var.alb_health_check_unhealthy_threshold
    matcher             = var.alb_health_check_matcher
  }
}

# Backend TG
resource "aws_lb_target_group" "backend_tg" {
  name     = "backend-tg-${var.name_suffix}"
  port     = var.backend_tg_port
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id
  health_check {
    path                = "/api/users/login"
    interval            = var.alb_health_check_interval
    timeout             = var.alb_health_check_timeout
    healthy_threshold   = var.alb_health_check_healthy_threshold
    unhealthy_threshold = var.alb_health_check_unhealthy_threshold
    matcher             = var.alb_health_check_matcher
  }
}

# Attach workers to TGs
resource "aws_lb_target_group_attachment" "frontend_attach" {
  count            = var.worker_count
  target_group_arn = aws_lb_target_group.frontend_tg.arn
  target_id        = aws_instance.worker[count.index].id
  port             = var.frontend_tg_port
}

resource "aws_lb_target_group_attachment" "backend_attach" {
  count            = var.worker_count
  target_group_arn = aws_lb_target_group.backend_tg.arn
  target_id        = aws_instance.worker[count.index].id
  port             = var.backend_tg_port
}

# Listener + Path rules
resource "aws_lb_listener" "app_listener" {
  load_balancer_arn = aws_lb.app_alb.arn
  port              = var.alb_http_port
  protocol          = var.alb_protocol

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.frontend_tg.arn
  }
}

resource "aws_lb_listener_rule" "backend_rule" {
  listener_arn = aws_lb_listener.app_listener.arn
  priority     = 10
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.backend_tg.arn
  }
  condition {
    path_pattern {
      values = ["/api/*"]
    }
  }
}

# ------------------------------
# Bastion Host
# ------------------------------
resource "aws_instance" "bastion" {
  ami                         = var.ami_id
  instance_type               = var.bastion_instance_type
  subnet_id                   = aws_subnet.public.id
  key_name                    = var.key_pair
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.bastion_sg.id]
  tags                        = merge(var.common_tags, { Name = "bastion-${var.name_suffix}" })
}

# ------------------------------
# Master Host
# ------------------------------
resource "aws_instance" "master" {
  ami                    = var.ami_id
  instance_type          = var.master_instance_type
  subnet_id              = aws_subnet.private.id
  key_name               = var.key_pair
  vpc_security_group_ids = [aws_security_group.private_sg.id]
  tags                   = merge(var.common_tags, { Name = "master-${var.name_suffix}" })

  root_block_device {
    volume_size           = var.root_volume_size
    volume_type           = var.root_volume_type
    delete_on_termination = true
  }
}

# ------------------------------
# Worker Hosts
# ------------------------------
resource "aws_instance" "worker" {
  count                  = var.worker_count
  ami                    = var.ami_id
  instance_type          = var.worker_instance_type
  subnet_id              = aws_subnet.private.id
  key_name               = var.key_pair
  vpc_security_group_ids = [aws_security_group.private_sg.id]
  tags                   = merge(var.common_tags, { Name = "worker${count.index + 1}-${var.name_suffix}" })

  root_block_device {
    volume_size           = var.root_volume_size
    volume_type           = var.root_volume_type
    delete_on_termination = true
  }
}
