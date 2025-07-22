#!/bin/bash

# Directory where Terraform configs are located
# TF_DIR=../terraform

# Directory to save Ansible inventory
# INVENTORY_DIR=./inventory

# Fetch Terraform outputs for IP addresses
# BASTION_IP=$(cd "$TF_DIR" && terraform output -raw bastion_public_ip)
# MASTER_IP=$(cd "$TF_DIR" && terraform output -raw master_private_ip)
# WORKER_IPS=$(cd "$TF_DIR" && terraform output -json worker_private_ips | jq -r '.[]')

# Create inventory directory if it doesn't exist
# mkdir -p "$INVENTORY_DIR"

# Write master group and configure SSH to connect through Bastion
# echo "[master]" > "${INVENTORY_DIR}/hosts.ini"
# echo "$MASTER_IP ansible_ssh_common_args='-o ProxyCommand=\"ssh -i ~/.ssh/azure-devops-key.pem -W %h:%p ec2-user@$BASTION_IP\" -o StrictHostKeyChecking=no'" >> "${INVENTORY_DIR}/hosts.ini"

# Blank line for readability in hosts.ini
# echo "" >> "${INVENTORY_DIR}/hosts.ini"

# Write worker group and configure SSH with ProxyCommand via Bastion
# echo "[worker]" >> "${INVENTORY_DIR}/hosts.ini"
# for ip in $WORKER_IPS; do
#   echo "$ip ansible_ssh_common_args='-o ProxyCommand=\"ssh -i ~/.ssh/azure-devops-key.pem -W %h:%p ec2-user@$BASTION_IP\" -o StrictHostKeyChecking=no'" >> "${INVENTORY_DIR}/hosts.ini"
# done

# Blank line for readability in hosts.ini
# echo "" >> "${INVENTORY_DIR}/hosts.ini"

# Define global Ansible variables for user and private key location
# echo "[all:vars]" >> "${INVENTORY_DIR}/hosts.ini"
# echo "ansible_user=ec2-user" >> "${INVENTORY_DIR}/hosts.ini"
# echo "ansible_ssh_private_key_file=~/.ssh/azure-devops-key.pem" >> "${INVENTORY_DIR}/hosts.ini"
