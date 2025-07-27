#!/bin/bash
set -e  # Exit on any command failure

TF_DIR=../terraform
INVENTORY_DIR=./inventory
KEY_PATH=$1   # Gets passed as $SSH_KEY from Jenkins

# Ensure inventory directory exists and is writable by the user running the script
mkdir -p "$INVENTORY_DIR"
# If necessary, fix permissions (only needed if you get permission denied errors)
# chown $USER:$USER "$INVENTORY_DIR"

# Fetch Terraform outputs
BASTION_IP=$(cd "$TF_DIR" && terraform output -raw bastion_public_ip)
MASTER_IP=$(cd "$TF_DIR" && terraform output -raw master_private_ip)
WORKER_IPS=$(cd "$TF_DIR" && terraform output -json worker_private_ips | jq -r '.[]')

# Create hosts.ini
HOSTS_FILE="${INVENTORY_DIR}/hosts.ini"

echo "[master]" > "$HOSTS_FILE"
echo "$MASTER_IP ansible_ssh_common_args='-o ProxyCommand=\"ssh -W %h:%p ec2-user@$BASTION_IP\" -o StrictHostKeyChecking=no'" >> "$HOSTS_FILE"

echo "" >> "$HOSTS_FILE"
echo "[worker]" >> "$HOSTS_FILE"
for ip in $WORKER_IPS; do
  echo "$ip ansible_ssh_common_args='-o ProxyCommand=\"ssh -W %h:%p ec2-user@$BASTION_IP\" -o StrictHostKeyChecking=no'" >> "$HOSTS_FILE"
done

echo "" >> "$HOSTS_FILE"
echo "[all:vars]" >> "$HOSTS_FILE"
echo "ansible_user=ec2-user" >> "$HOSTS_FILE"
