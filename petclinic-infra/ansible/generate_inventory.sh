#!/bin/bash
set -e  # Exit on any error

TF_DIR=../terraform
INVENTORY_DIR=./inventory
KEY_PATH=$1   # Passed as $SSH_KEY from Jenkins

# Ensure inventory directory exists
mkdir -p "$INVENTORY_DIR"

# Fetch Terraform outputs
BASTION_IP=$(cd "$TF_DIR" && terraform output -raw bastion_public_ip)
MASTER_IP=$(cd "$TF_DIR" && terraform output -raw master_private_ip)
WORKER_IPS=$(cd "$TF_DIR" && terraform output -json worker_private_ips | jq -r '.[]')

# Create hosts.ini
HOSTS_FILE="${INVENTORY_DIR}/hosts.ini"

echo "[master]" > "$HOSTS_FILE"
echo "$MASTER_IP ansible_ssh_common_args='-o ProxyCommand=\"ssh -A -i $KEY_PATH -W %h:%p ec2-user@$BASTION_IP\" -o StrictHostKeyChecking=no'" >> "$HOSTS_FILE"

echo "" >> "$HOSTS_FILE"
echo "[worker]" >> "$HOSTS_FILE"
for ip in $WORKER_IPS; do
  echo "$ip ansible_ssh_common_args='-o ProxyCommand=\"ssh -A -i $KEY_PATH -W %h:%p ec2-user@$BASTION_IP\" -o StrictHostKeyChecking=no'" >> "$HOSTS_FILE"
done

echo "" >> "$HOSTS_FILE"
echo "[all:vars]" >> "$HOSTS_FILE"
echo "ansible_user=ec2-user" >> "$HOSTS_FILE"
