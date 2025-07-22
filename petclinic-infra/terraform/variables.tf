# variable "aws_region" {                         # AWS region where resources will be deployed
#   description = "The AWS region to deploy resources in"
#   type        = string
#   default     = "us-east-1"
# }

# variable "vpc_cidr_block" {                    # IP range for your Virtual Private Cloud (VPC)
#   description = "CIDR block for the VPC"
#   type        = string
#   default     = "10.0.0.0/16"
# }

# variable "subnet_cidr_block" {                 # IP range for your Subnet (inside the VPC)
#   description = "CIDR block for the subnet"
#   type        = string
#   default     = "10.0.1.0/24"
# }

# variable "availability_zone" {                 # Specific AZ (like us-east-1a) to place your subnet in
#   description = "Availability zone for the subnet"
#   type        = string
#   default     = "us-east-1a"
# }

# variable "key_pair" {                          # Name of your SSH key pair to access EC2 instances
#   description = "Name of the AWS SSH key pair"
#   type        = string
# }

# variable "ami_id" {                            # ID of the base machine image used for EC2 instances
#   description = "AMI ID to use for all instances"
#   type        = string
#   default     = "ami-0c02fb55956c7d316"
# }

# variable "bastion_instance_type" {             # EC2 instance type for Bastion host (entry point to network)
#   description = "Instance type for the bastion host"
#   type        = string
#   default     = "t2.micro"
# }

# variable "master_instance_type" {              # EC2 instance type for Kubernetes master node
#   description = "Instance type for the Kubernetes master node"
#   type        = string
#   default     = "t2.medium"
# }

# variable "worker_instance_type" {              # EC2 instance type for Kubernetes worker nodes
#   description = "Instance type for the Kubernetes worker node"
#   type        = string
#   default     = "t2.medium"
# }

# variable "worker_count" {                      # How many Kubernetes worker nodes to create
#   description = "Number of worker nodes to deploy"
#   type        = number
#   default     = 2
# }

# variable "ci_host_ip" {                        # IP of the Jenkins (or CI/CD tool) host to allow SSH/API
#   description = "Public IP of the CI/CD system that should have SSH/API access"
#   type        = string
# }

# variable "common_tags" {                       # Tags to apply to all AWS resources (e.g., ownership)
#   description = "Common tags applied to all resources"
#   type        = map(string)
#   default = {
#     Owner1 = "Omar Khaled"
#     Owner2 = "Salma Walid"
#     Owner3 = "Mariam Hesham"
#   }
# }

# variable "name_suffix" {                       # Optional name suffix to be added to all resources
#   description = "Suffix to append to resource name tags"
#   type        = string
#   default     = "--- Red Team"
# }

# variable "ssh_port" {                          # SSH port number to allow on EC2 instances (default is 22)
#   description = "SSH port number"
#   type        = number
#   default     = 22
# }

# variable "k8s_api_port" {                      # Port used by Kubernetes API server on the master node
#   description = "Kubernetes API server port"
#   type        = number
#   default     = 6443
# }

# variable "egress_from_port" {                  # Start port for allowed outgoing traffic
#   description = "Egress rule starting port"
#   type        = number
#   default     = 0
# }

# variable "egress_to_port" {                    # End port for allowed outgoing traffic
#   description = "Egress rule ending port"
#   type        = number
#   default     = 0
# }

# variable "egress_protocol" {                   # Protocol used in egress (usually "-1" means all)
#   description = "Egress rule protocol"
#   type        = string
#   default     = "-1"
# }

# variable "egress_cidr_blocks" {                # IPs allowed for outgoing traffic (0.0.0.0/0 = all)
#   description = "CIDR blocks allowed for outbound traffic"
#   type        = list(string)
#   default     = ["0.0.0.0/0"]
# }
