output "vpc_id" {
  description = "The ID of the VPC"  # Provides the ID of the VPC for referencing in other tools.
  value       = aws_vpc.main.id
}

output "subnet_id" {
  description = "The ID of the subnet"  # Provides the ID of the subnet for routing or placement.
  value       = aws_subnet.main.id
}

output "security_group_id" {
  description = "The ID of the Kubernetes security group"  # Helps reference network rules.
  value       = aws_security_group.k8s_sg.id
}

output "bastion_public_ip" {
  description = "Public IP of the bastion host"  # Used for external SSH access.
  value       = aws_instance.bastion.public_ip
}

output "bastion_private_ip" {
  description = "Private IP of the bastion host"  # Used for internal network access.
  value       = aws_instance.bastion.private_ip
}

output "master_private_ip" {
  description = "Private IP of the Kubernetes master node"  # Required for Kubernetes setup.
  value       = aws_instance.master.private_ip
}

output "worker_private_ips" {
  description = "List of private IPs of the Kubernetes worker nodes"  # Allows joining the cluster.
  value       = [for instance in aws_instance.worker : instance.private_ip]
}

output "bastion_instance_id" {
  description = "Instance ID of the bastion host"  # Useful for automation and tracking.
  value       = aws_instance.bastion.id
}

output "master_instance_id" {
  description = "Instance ID of the master node"  # For tracking and applying logic.
  value       = aws_instance.master.id
}

output "worker_instance_ids" {
  description = "List of instance IDs of the worker nodes"  # Useful for monitoring.
  value       = [for instance in aws_instance.worker : instance.id]
}