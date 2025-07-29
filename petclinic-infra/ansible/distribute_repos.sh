#!/bin/bash
set -e
TF_DIR=../terraform
INVENTORY_DIR=./inventory
KEY_PATH=$1  # Passed as argument from Jenkins (e.g., ./generate_inventory.sh mykey.pem)

# Fetch Terraform outputs
echo "🔍 Fetching Terraform outputs..."
BASTION_IP=$(cd "$TF_DIR" && terraform output -raw bastion_public_ip)
MASTER_IP=$(cd "$TF_DIR" && terraform output -raw master_private_ip)
WORKER_IPS=$(cd "$TF_DIR" && terraform output -json worker_private_ips | jq -r '.[]')

echo "Starting repo distribution workaround..."

echo "Fetching repo data on bastion..."
ssh -o StrictHostKeyChecking=no -i "$KEY_PATH" ec2-user@"$BASTION_IP" << EOF
  sudo yum makecache
  mkdir -p ~/amzn2-repos
  sudo cp -r /etc/yum.repos.d ~/amzn2-repos/
  sudo cp -r /var/cache/yum ~/amzn2-repos/
EOF

echo "Copying repo data to master and workers..."
for ip in "$MASTER_IP" "${WORKER_IPS[@]}"; do
  ssh -o StrictHostKeyChecking=no -i "$KEY_PATH" ec2-user@"$BASTION_IP" \
    "scp -o StrictHostKeyChecking=no -i ~/.ssh/id_rsa -r ~/amzn2-repos ec2-user@$ip:/tmp/"
done

echo "Updating YUM cache on master and workers..."
for ip in "$MASTER_IP" "${WORKER_IPS[@]}"; do
  ssh -o StrictHostKeyChecking=no -i "$KEY_PATH" ec2-user@"$BASTION_IP" \
    "ssh -o StrictHostKeyChecking=no -i ~/.ssh/id_rsa ec2-user@$ip 'sudo cp -r /tmp/amzn2-repos/yum.repos.d /etc/ && sudo cp -r /tmp/amzn2-repos/yum /var/cache/ && sudo yum clean all && sudo yum makecache'"
done

echo "Repo workaround completed successfully!"
