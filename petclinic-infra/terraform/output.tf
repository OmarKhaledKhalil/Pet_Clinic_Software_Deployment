# --- ALB Outputs ---
output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = aws_lb.app_alb.dns_name
}

output "alb_arn" {
  description = "ARN of the Application Load Balancer"
  value       = aws_lb.app_alb.arn
}

output "frontend_tg_arn" {
  description = "ARN of the frontend ALB target group"
  value       = aws_lb_target_group.frontend_tg.arn
}

output "backend_tg_arn" {
  description = "ARN of the backend ALB target group"
  value       = aws_lb_target_group.backend_tg.arn
}

# --- VPC/Subnet Outputs ---
output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.main.id
}

output "public_subnet_id" {
  description = "The ID of the public subnet"
  value       = aws_subnet.public.id
}

output "public_subnet_2_id" {
  description = "The ID of the second public subnet"
  value       = aws_subnet.public_2.id
}

output "private_subnet_id" {
  description = "The ID of the private subnet"
  value       = aws_subnet.private.id
}

# --- EC2 Outputs for Ansible ---
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
