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

# Prepare SSH args for bastion proxy jump
SSH_COMMON_ARGS="-o ProxyCommand=ssh -i $KEY_PATH -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -W %h:%p ec2-user@$BASTION_IP -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null"

# Create hosts.ini
HOSTS_FILE="${INVENTORY_DIR}/hosts.ini"

{
echo "[master]"
echo "$MASTER_IP ansible_ssh_common_args='$SSH_COMMON_ARGS'"

echo ""
echo "[worker]"
for ip in $WORKER_IPS; do
  echo "$ip ansible_ssh_common_args='$SSH_COMMON_ARGS'"
done

echo ""
echo "[all:vars]"
echo "ansible_user=ec2-user"
} > "$HOSTS_FILE"

# Optional: validate generated inventory
echo "🔍 Validating generated inventory..."
ansible-inventory -i "$HOSTS_FILE" --list > /dev/null && echo "✅ Inventory is valid."
