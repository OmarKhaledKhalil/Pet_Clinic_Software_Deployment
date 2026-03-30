#!/bin/bash
set -e

KEY_PATH=$1
TF_OUTPUT_JSON=$2

INVENTORY_DIR=./inventory
mkdir -p "$INVENTORY_DIR"
HOSTS_FILE="${INVENTORY_DIR}/hosts.ini"

echo "Generating Ansible inventory..."

BASTION_IP=$(jq -r .bastion_public_ip.value "$TF_OUTPUT_JSON")
MASTER_IP=$(jq -r .master_private_ip.value "$TF_OUTPUT_JSON")
WORKER_IPS=$(jq -r '.worker_private_ips.value[]' "$TF_OUTPUT_JSON")

echo "[master]" > "$HOSTS_FILE"
echo "${MASTER_IP} ansible_ssh_common_args='-o ProxyCommand=\"ssh -i ${KEY_PATH} -W %h:%p ec2-user@${BASTION_IP}\" -o StrictHostKeyChecking=no'" >> "$HOSTS_FILE"

echo -e "\n[worker]" >> "$HOSTS_FILE"
for ip in $WORKER_IPS; do
  echo "${ip} ansible_ssh_common_args='-o ProxyCommand=\"ssh -i ${KEY_PATH} -W %h:%p ec2-user@${BASTION_IP}\" -o StrictHostKeyChecking=no'" >> "$HOSTS_FILE"
done

echo -e "\n[all:vars]" >> "$HOSTS_FILE"
echo "ansible_user=ubuntu" >> "$HOSTS_FILE"

echo "Inventory generated at $HOSTS_FILE"
