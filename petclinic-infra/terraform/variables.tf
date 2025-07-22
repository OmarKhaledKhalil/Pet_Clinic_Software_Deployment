variable "aws_region" {
  description = "The AWS region to deploy resources in"  # Defines where resources will be created.
  type        = string
  default     = "us-east-1"
}

variable "vpc_cidr_block" {
  description = "CIDR block for the VPC"  # Specifies the IP range for the VPC.
  type        = string
  default     = "10.0.0.0/16"
}

variable "subnet_cidr_block" {
  description = "CIDR block for the subnet"  # Defines the IP range for the subnet within the VPC.
  type        = string
  default     = "10.0.1.0/24"
}

variable "availability_zone" {
  description = "Availability zone for the subnet"  # Specifies the AZ for resource redundancy and availability.
  type        = string
  default     = "us-east-1a"
}

variable "key_pair" {
  description = "Name of the AWS SSH key pair"  # Used to SSH into EC2 instances.
  type        = string
}

variable "ami_id" {
  description = "AMI ID to use for all instances"  # Base image for launching instances.
  type        = string
  default     = "ami-0c02fb55956c7d316"
}

variable "bastion_instance_type" {
  description = "Instance type for the bastion host"  # Determines the resources for the bastion.
  type        = string
  default     = "t2.micro"
}

variable "master_instance_type" {
  description = "Instance type for the Kubernetes master node"  # Defines resources for the master node.
  type        = string
  default     = "t2.medium"
}

variable "worker_instance_type" {
  description = "Instance type for the Kubernetes worker node"  # Sets the resources for each worker node.
  type        = string
  default     = "t2.medium"
}

variable "worker_count" {
  description = "Number of worker nodes to deploy"  # Specifies how many workers to create.
  type        = number
  default     = 2
}

variable "ci_host_ip" {
  description = "Public IP of the CI/CD system that should have SSH/API access"  # Restricts access to specific IP.
  type        = string
}

variable "common_tags" {
  description = "Common tags applied to all resources"  # Tags for resource identification and ownership.
  type        = map(string)
  default = {
    Owner1 = "Omar Khaled"
    Owner2 = "Salma Walid"
    Owner3 = "Mariam Hesham"
  }
}

variable "name_suffix" {
  description = "Suffix to append to resource name tags"  # Helps differentiate environments or groups.
  type        = string
  default     = "--- Red Team"
}

variable "ssh_port" {
  description = "SSH port number"  # Port used for SSH access.
  type        = number
  default     = 22
}

variable "k8s_api_port" {
  description = "Kubernetes API server port"  # Port for the Kubernetes API on the master node.
  type        = number
  default     = 6443
}

variable "egress_from_port" {
  description = "Egress rule starting port"  # Starting point for outbound traffic rules.
  type        = number
  default     = 0
}

variable "egress_to_port" {
  description = "Egress rule ending port"  # Ending point for outbound traffic rules.
  type        = number
  default     = 0
}

variable "egress_protocol" {
  description = "Egress rule protocol"  # Protocol for egress rules, where "-1" means all protocols.
  type        = string
  default     = "-1"
}

variable "egress_cidr_blocks" {
  description = "CIDR blocks allowed for outbound traffic"  # Defines allowed outbound traffic destinations.
  type        = list(string)
  default     = ["0.0.0.0/0"]
}