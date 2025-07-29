#!/bin/bash
set -e  # Exit on any error

# Define paths
TF_DIR=../terraform
INVENTORY_DIR=./inventory
KEY_PATH=$1  # Passed as argument from Jenkins (e.g., ./generate_inventory.sh mykey.pem)

# Ensure inventory directory exists
mkdir -p "$INVENTORY_DIR"

# Fetch Terraform outputs
echo "🔍 Fetching Terraform outputs..."
BASTION_IP=$(cd "$TF_DIR" && terraform output -raw bastion_public_ip)
MASTER_IP=$(cd "$TF_DIR" && terraform output -raw master_private_ip)
WORKER_IPS=$(cd "$TF_DIR" && terraform output -json worker_private_ips | jq -r '.[]')

# Create hosts.ini
HOSTS_FILE="${INVENTORY_DIR}/hosts.ini"
echo "🔧 Generating $HOSTS_FILE..."

# Master section
echo "[master]" > "$HOSTS_FILE"
echo "${MASTER_IP} ansible_ssh_common_args='-o ProxyCommand=\"ssh -A -i ${KEY_PATH} -W %h:%p ec2-user@${BASTION_IP}\" -o StrictHostKeyChecking=no'" >> "$HOSTS_FILE"

# Worker section
echo -e "\n[worker]" >> "$HOSTS_FILE"
for ip in $WORKER_IPS; do
  echo "${ip} ansible_ssh_common_args='-o ProxyCommand=\"ssh -A -i ${KEY_PATH} -W %h:%p ec2-user@${BASTION_IP}\" -o StrictHostKeyChecking=no'" >> "$HOSTS_FILE"
done

# Global variables section
echo -e "\n[all:vars]" >> "$HOSTS_FILE"
echo "ansible_user=ec2-user" >> "$HOSTS_FILE"

echo "✅ Inventory file generated at $HOSTS_FILE"
