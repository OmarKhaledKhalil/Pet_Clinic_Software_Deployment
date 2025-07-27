#!/bin/bash

echo "🔧 Starting inventory generation script"

INVENTORY_FILE="inventory/hosts.ini"
KEY_PATH="$1"

echo "📍 SSH Key Path passed: $KEY_PATH"
echo "📍 Terraform Directory: ../terraform"

echo "🌐 Fetching Bastion Public IP from Terraform output..."
BASTION_PUBLIC_IP=$(terraform -chdir=../terraform output -raw bastion_public_ip)
echo "🔹 Bastion Public IP: $BASTION_PUBLIC_IP"

echo "🌐 Fetching Master Private IP..."
MASTER_PRIVATE_IP=$(terraform -chdir=../terraform output -raw master_private_ip)
echo "🔹 Master Private IP: $MASTER_PRIVATE_IP"

echo "🌐 Fetching Worker Private IPs..."
WORKER_PRIVATE_IPS=$(terraform -chdir=../terraform output -json worker_private_ips | jq -r '.[]')
echo "🔹 Worker Private IPs:"
echo "$WORKER_PRIVATE_IPS"

echo "📁 Creating inventory directory if not exists"
mkdir -p inventory

echo "📝 Writing master node to inventory"
cat > "$INVENTORY_FILE" <<EOF
[master]
$MASTER_PRIVATE_IP ansible_ssh_common_args='-o ProxyJump=ec2-user@$BASTION_PUBLIC_IP -o StrictHostKeyChecking=no'

[worker]
EOF

echo "📝 Writing worker nodes to inventory"
for ip in $WORKER_PRIVATE_IPS; do
  echo "$ip ansible_ssh_common_args='-o ProxyJump=ec2-user@$BASTION_PUBLIC_IP -o StrictHostKeyChecking=no'" >> "$INVENTORY_FILE"
done

echo "📝 Writing global variables"
cat >> "$INVENTORY_FILE" <<EOF

[all:vars]
ansible_user=ec2-user
ansible_ssh_private_key_file=$KEY_PATH
EOF

echo "✅ Inventory successfully generated at: $INVENTORY_FILE"
echo "📂 Final inventory file content:"
cat "$INVENTORY_FILE"
