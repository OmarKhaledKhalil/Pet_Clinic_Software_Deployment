#!/bin/bash
set -e

if [ "$#" -ne 4 ]; then
  echo "Usage: $0 <SSH_KEY_PATH> <BASTION_IP> <MASTER_IP> <WORKER_IPS(comma-separated)>"
  exit 1
fi

KEY_PATH=$1
BASTION_IP=$2
MASTER_IP=$3
WORKER_IPS_CSV=$4

IFS=',' read -ra WORKER_IPS <<< "$WORKER_IPS_CSV"

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
