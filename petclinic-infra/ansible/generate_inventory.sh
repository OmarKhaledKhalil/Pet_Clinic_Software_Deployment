#!/bin/bash

echo "🔧 Generating inventory"

# Variables
INVENTORY_FILE="inventory/hosts.ini"
KEY_PATH="/home/vagrant/Pet_Clinic_Software_Deployment/petclinic-infra/jenkins-key.pem"
BASTION_PUBLIC_IP=$(terraform -chdir=../terraform output -raw bastion_public_ip)
MASTER_PRIVATE_IP=$(terraform -chdir=../terraform output -raw master_private_ip)
WORKER_PRIVATE_IPS=$(terraform -chdir=../terraform output -json worker_private_ips | jq -r '.[]')

# Ensure inventory directory exists
mkdir -p inventory

# Start writing inventory file
cat > "$INVENTORY_FILE" <<EOF
[master]
$MASTER_PRIVATE_IP ansible_ssh_common_args='-o ProxyCommand="ssh -i $KEY_PATH -W %h:%p ec2-user@$BASTION_PUBLIC_IP" -o StrictHostKeyChecking=no'

[worker]
EOF

# Append each worker private IP
for ip in $WORKER_PRIVATE_IPS; do
  echo "$ip ansible_ssh_common_args='-o ProxyCommand=\"ssh -i $KEY_PATH -W %h:%p ec2-user@$BASTION_PUBLIC_IP\" -o StrictHostKeyChecking=no'" >> "$INVENTORY_FILE"
done

# Global variables
cat >> "$INVENTORY_FILE" <<EOF

[all:vars]
ansible_user=ec2-user
ansible_ssh_private_key_file=$KEY_PATH
EOF

echo "✅ Inventory generated at $INVENTORY_FILE"
