# Output the ID of the created VPC
output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.main.id
}

# Output the ID of the created subnet
output "subnet_id" {
  description = "The ID of the subnet"
  value       = aws_subnet.main.id
}

# Output the ID of the security group used for Kubernetes nodes
output "security_group_id" {
  description = "The ID of the Kubernetes security group"
  value       = aws_security_group.k8s_sg.id
}

# Output the public IP of the bastion host (used for SSH access from outside)
output "bastion_public_ip" {
  description = "Public IP of the bastion host"
  value       = aws_instance.bastion.public_ip
}

# Output the private IP of the bastion host (used internally within the VPC)
output "bastion_private_ip" {
  description = "Private IP of the bastion host"
  value       = aws_instance.bastion.private_ip
}

# Output the private IP of the master node (used for internal Kubernetes communication)
output "master_private_ip" {
  description = "Private IP of the Kubernetes master node"
  value       = aws_instance.master.private_ip
}

# Output a list of private IPs for all Kubernetes worker nodes
output "worker_private_ips" {
  description = "List of private IPs of the Kubernetes worker nodes"
  value       = [for instance in aws_instance.worker : instance.private_ip]
}

# Output the EC2 instance ID of the bastion host (useful for AWS CLI or automation)
output "bastion_instance_id" {
  description = "Instance ID of the bastion host"
  value       = aws_instance.bastion.id
}

# Output the EC2 instance ID of the master node
output "master_instance_id" {
  description = "Instance ID of the master node"
  value       = aws_instance.master.id
}

# Output a list of EC2 instance IDs for all worker nodes
output "worker_instance_ids" {
  description = "List of instance IDs of the worker nodes"
  value       = [for instance in aws_instance.worker : instance.id]
}
