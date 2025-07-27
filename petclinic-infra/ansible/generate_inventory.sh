#!/bin/bash

echo "🔧 Starting inventory generation..."

INVENTORY_FILE="inventory/hosts.ini"
KEY_PATH="$1"
echo "📌 SSH key path: $KEY_PATH"

echo "📡 Fetching Terraform outputs..."
BASTION_PUBLIC_IP=$(terraform -chdir=../terraform output -raw bastion_public_ip)
MASTER_PRIVATE_IP=$(terraform -chdir=../terraform output -raw master_private_ip)
WORKER_PRIVATE_IPS=$(terraform -chdir=../terraform output -json worker_private_ips | jq -r '.[]')

echo "✅ BASTION_PUBLIC_IP: $BASTION_PUBLIC_IP"
echo "✅ MASTER_PRIVATE_IP: $MASTER_PRIVATE_IP"
echo "✅ WORKER_PRIVATE_IPS:"
echo "$WORKER_PRIVATE_IPS"

echo "📁 Creating inventory directory..."
mkdir -p inventory

echo "📝 Writing master node to inventory..."
cat > "$INVENTORY_FILE" <<EOF
[master]
$MASTER_PRIVATE_IP ansible_ssh_common_args='-o ProxyJump=ec2-user@$BASTION_PUBLIC_IP -o StrictHostKeyChecking=no'

[worker]
EOF

echo "📝 Adding worker nodes to inventory..."
for ip in $WORKER_PRIVATE_IPS; do
  echo "$ip ansible_ssh_common_args='-o ProxyJump=ec2-user@$BASTION_PUBLIC_IP -o StrictHostKeyChecking=no'" >> "$INVENTORY_FILE"
done

echo "📝 Writing global vars..."
cat >> "$INVENTORY_FILE" <<EOF

[all:vars]
ansible_user=ec2-user
ansible_ssh_private_key_file=$KEY_PATH
EOF

echo "📄 Final generated inventory:"
cat "$INVENTORY_FILE"

echo "✅ Inventory generation completed."
