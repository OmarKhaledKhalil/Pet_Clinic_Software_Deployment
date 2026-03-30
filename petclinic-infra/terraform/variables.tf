variable "aws_region" {
  description = "The AWS region to deploy resources in"
  type        = string
  default     = "us-east-1"
}

variable "availability_zone" {
  description = "Availability zone for the subnets"
  type        = string
  default     = "us-east-1a"
}

variable "vpc_cidr_block" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr_block" {
  description = "CIDR block for the public subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "private_subnet_cidr_block" {
  description = "CIDR block for the private subnet"
  type        = string
  default     = "10.0.2.0/24"
}

variable "default_cidr_block" {
  description = "Default CIDR block for route tables and open SG rules"
  type        = string
  default     = "0.0.0.0/0"
}

variable "key_pair" {
  description = "Name of the AWS SSH key pair"
  type        = string
}

variable "ami_id" {
  description = "AMI ID to use for all instances"
  type        = string
  default     = "ami-020cba7c55df1f615"
}

variable "bastion_instance_type" {
  description = "Instance type for the bastion host"
  type        = string
  default     = "t2.micro"
}

variable "master_instance_type" {
  description = "Instance type for the Kubernetes master node"
  type        = string
  default     = "t2.medium"
}

variable "worker_instance_type" {
  description = "Instance type for the Kubernetes worker nodes"
  type        = string
  default     = "t2.medium"
}

variable "worker_count" {
  description = "Number of worker nodes to deploy"
  type        = number
  default     = 2
}

variable "root_volume_size" {
  description = "Root EBS volume size in GiB"
  type        = number
  default     = 50
}

variable "root_volume_type" {
  description = "Root EBS volume type"
  type        = string
  default     = "gp3"
}

variable "external_access_ip" {
  description = "Public IP address for external access to bastion"
  type        = string
}

variable "ssh_port" {
  description = "SSH port number"
  type        = number
  default     = 22
}

variable "egress_from_port" {
  description = "Egress rule starting port"
  type        = number
  default     = 0
}

variable "egress_to_port" {
  description = "Egress rule ending port"
  type        = number
  default     = 0
}

variable "egress_protocol" {
  description = "Egress rule protocol"
  type        = string
  default     = "-1"
}

variable "egress_cidr_blocks" {
  description = "CIDR blocks allowed for outbound traffic"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "common_tags" {
  description = "Common tags applied to all resources"
  type        = map(string)
  default = {
    Owner1 = "Omar Khaled"
    Owner2 = "Salma Walid"
    Owner3 = "Mariam Hesham"
  }
}

variable "name_suffix" {
  description = "Suffix to append to resource name tags"
  type        = string
  default     = "red-team"
}

# ALB Configuration
variable "alb_http_port" {
  description = "HTTP port for the Application Load Balancer"
  type        = number
  default     = 80
}

variable "alb_https_port" {
  description = "HTTPS port for the Application Load Balancer"
  type        = number
  default     = 443
}

variable "alb_protocol" {
  description = "Protocol for the Application Load Balancer listener"
  type        = string
  default     = "HTTP"
}

variable "alb_health_check_path" {
  description = "Health check path for the frontend target group"
  type        = string
  default     = "/"
}

variable "alb_health_check_interval" {
  description = "Interval (in seconds) for ALB health checks"
  type        = number
  default     = 30
}

variable "alb_health_check_timeout" {
  description = "Timeout (in seconds) for ALB health checks"
  type        = number
  default     = 5
}

variable "alb_health_check_healthy_threshold" {
  description = "Number of consecutive health check successes before considering target healthy"
  type        = number
  default     = 2
}

variable "alb_health_check_unhealthy_threshold" {
  description = "Number of consecutive health check failures before considering target unhealthy"
  type        = number
  default     = 2
}

variable "alb_health_check_matcher" {
  description = "HTTP codes to match for healthy status"
  type        = string
  default     = "200-399"
}

variable "public_subnet_cidr_block_2" {
  description = "CIDR block for the second public subnet"
  type        = string
  default     = "10.0.3.0/24"
}

variable "availability_zone_2" {
  description = "Second availability zone"
  type        = string
  default     = "us-east-1b"
}

# New: TG ports
variable "frontend_tg_port" {
  description = "Port for the frontend target group and attachments"
  type        = number
  default     = 30070
}

variable "backend_tg_port" {
  description = "Port for the backend target group and attachments"
  type        = number
  default     = 30073
}
