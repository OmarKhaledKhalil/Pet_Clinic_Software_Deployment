#!/bin/bash

echo "🔧 Generating inventory"

INVENTORY_FILE="inventory/hosts.ini"
KEY_PATH="$1"
BASTION_PUBLIC_IP=$(terraform -chdir=../terraform output -raw bastion_public_ip)
MASTER_PRIVATE_IP=$(terraform -chdir=../terraform output -raw master_private_ip)
WORKER_PRIVATE_IPS=$(terraform -chdir=../terraform output -json worker_private_ips | jq -r '.[]')

mkdir -p inventory

cat > "$INVENTORY_FILE" <<EOF
[master]
$MASTER_PRIVATE_IP ansible_ssh_common_args='-o ProxyJump=ec2-user@$BASTION_PUBLIC_IP -o StrictHostKeyChecking=no'

[worker]
EOF

for ip in $WORKER_PRIVATE_IPS; do
  echo "$ip ansible_ssh_common_args='-o ProxyJump=ec2-user@$BASTION_PUBLIC_IP -o StrictHostKeyChecking=no'" >> "$INVENTORY_FILE"
done

cat >> "$INVENTORY_FILE" <<EOF

[all:vars]
ansible_user=ec2-user
ansible_ssh_private_key_file=$KEY_PATH
EOF

echo "✅ Inventory generated at $INVENTORY_FILE"
