# -------------------------------
# Output the ID of the created VPC
# Used to reference the main VPC in other tools or modules
# -------------------------------
output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.main.id
}

# -------------------------------
# Output the ID of the created subnet (public or private)
# Useful for subnet-related routing or instance placement
# -------------------------------
output "subnet_id" {
  description = "The ID of the subnet"
  value       = aws_subnet.main.id
}

# -------------------------------
# Output the ID of the Kubernetes security group
# Helps configure or reference network rules in Ansible or CD scripts
# -------------------------------
output "security_group_id" {
  description = "The ID of the Kubernetes security group"
  value       = aws_security_group.k8s_sg.id
}

# -------------------------------
# Output the Public IP of Bastion Host
# Used for SSH access from your machine to the private network
# -------------------------------
output "bastion_public_ip" {
  description = "Public IP of the bastion host"
  value       = aws_instance.bastion.public_ip
}

# -------------------------------
# Output the Private IP of Bastion Host
# Used to allow master and workers to reach Bastion internally
# -------------------------------
output "bastion_private_ip" {
  description = "Private IP of the bastion host"
  value       = aws_instance.bastion.private_ip
}

# -------------------------------
# Output the Private IP of Master Node
# Required for internal Kubernetes setup and Ansible configuration
# -------------------------------
output "master_private_ip" {
  description = "Private IP of the Kubernetes master node"
  value       = aws_instance.master.private_ip
}

# -------------------------------
# Output the Private IPs of Worker Nodes (list)
# Needed by Ansible and K8s setup to join the cluster
# -------------------------------
output "worker_private_ips" {
  description = "List of private IPs of the Kubernetes worker nodes"
  value       = [for instance in aws_instance.worker : instance.private_ip]
}

# -------------------------------
# Output EC2 instance ID of Bastion Host
# Useful for automation, tagging, or state tracking
# -------------------------------
output "bastion_instance_id" {
  description = "Instance ID of the bastion host"
  value       = aws_instance.bastion.id
}

# -------------------------------
# Output EC2 instance ID of Master Node
# Good for tracking the master server or applying custom logic
# -------------------------------
output "master_instance_id" {
  description = "Instance ID of the master node"
  value       = aws_instance.master.id
}

# -------------------------------
# Output EC2 instance IDs of Worker Nodes (list)
# Useful for parallel configuration or monitoring
# -------------------------------
output "worker_instance_ids" {
  description = "List of instance IDs of the worker nodes"
  value       = [for instance in aws_instance.worker : instance.id]
}
