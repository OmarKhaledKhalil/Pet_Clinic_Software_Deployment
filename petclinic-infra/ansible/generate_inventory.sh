#!/bin/bash

#TF_DIR=../terraform
#INVENTORY_DIR=./inventory

# Fetch Terraform outputs
#BASTION_IP=$(cd "$TF_DIR" && terraform output -raw bastion_public_ip)
#MASTER_IP=$(cd "$TF_DIR" && terraform output -raw master_private_ip)
#WORKER_IPS=$(cd "$TF_DIR" && terraform output -json worker_private_ips | jq -r '.[]')

# Create inventory
#mkdir -p "$INVENTORY_DIR"
#echo "[master]" > "${INVENTORY_DIR}/hosts.ini"
#echo "$MASTER_IP ansible_ssh_common_args='-o ProxyCommand=\"ssh -i ~/.ssh/jenkins-key.pem -W %h:%p ec2-user@$BASTION_IP\" -o StrictHostKeyChecking=no'" >> "${INVENTORY_DIR}/hosts.ini"

#echo "" >> "${INVENTORY_DIR}/hosts.ini"
#echo "[worker]" >> "${INVENTORY_DIR}/hosts.ini"
#for ip in $WORKER_IPS; do
  #echo "$ip ansible_ssh_common_args='-o ProxyCommand=\"ssh -i ~/.ssh/jenkins-key.pem -W %h:%p ec2-user@$BASTION_IP\" -o StrictHostKeyChecking=no'" >> "${INVENTORY_DIR}/hosts.ini"
#done

#echo "" >> "${INVENTORY_DIR}/hosts.ini"
#echo "[all:vars]" >> "${INVENTORY_DIR}/hosts.ini"
#echo "ansible_user=ec2-user" >> "${INVENTORY_DIR}/hosts.ini"
#echo "ansible_ssh_private_key_file=~/.ssh/jenkins-key.pem" >> "${INVENTORY_DIR}/hosts.ini"
