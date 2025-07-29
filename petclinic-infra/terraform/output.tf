output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.main.id
}

output "public_subnet_id" {
  description = "The ID of the public subnet"
  value       = aws_subnet.public.id
}

output "private_subnet_id" {
  description = "The ID of the private subnet"
  value       = aws_subnet.private.id
}

# Uncomment and adjust the security group output once you declare a security group resource.
# output "security_group_id" {
#   description = "The ID of the Kubernetes security group"
#   value       = aws_security_group.k8s_sg.id
# }

output "bastion_public_ip" {
  description = "Public IP of the bastion host"
  value       = aws_instance.bastion.public_ip
}

output "bastion_private_ip" {
  description = "Private IP of the bastion host"
  value       = aws_instance.bastion.private_ip
}

output "master_private_ip" {
  description = "Private IP of the Kubernetes master node"
  value       = aws_instance.master.private_ip
}

output "worker_private_ips" {
  description = "List of private IPs of the Kubernetes worker nodes"
  value       = [for instance in aws_instance.worker : instance.private_ip]
}

output "bastion_instance_id" {
  description = "Instance ID of the bastion host"
  value       = aws_instance.bastion.id
}

output "master_instance_id" {
  description = "Instance ID of the master node"
  value       = aws_instance.master.id
}

output "worker_instance_ids" {
  description = "List of instance IDs of the worker nodes"
  value       = [for instance in aws_instance.worker : instance.id]
}
