variable "aws_region" {
  description = "The AWS region to deploy resources in"
  type        = string
  default     = "us-east-1"
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

variable "availability_zone" {
  description = "Availability zone for the subnets"
  type        = string
  default     = "us-east-1a"
}

variable "key_pair" {
  description = "Name of the AWS SSH key pair"
  type        = string
}

variable "ami_id" {
  description = "AMI ID to use for all instances"
  type        = string
  default     = "ami-0c02fb55956c7d316"
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
  description = "Instance type for the Kubernetes worker node"
  type        = string
  default     = "t2.medium"
}

variable "worker_count" {
  description = "Number of worker nodes to deploy"
  type        = number
  default     = 2
}

variable "jenkins_host_ip" {
  description = "Public IP of Jenkins host for access/security groups"
  type        = string
}

variable "ci_host_ip" {
  description = "Public IP of the CI/CD system that should have SSH/API access"
  type        = string
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

variable "ssh_port" {
  description = "SSH port number"
  type        = number
  default     = 22
}

variable "k8s_api_port" {
  description = "Kubernetes API server port"
  type        = number
  default     = 6443
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
