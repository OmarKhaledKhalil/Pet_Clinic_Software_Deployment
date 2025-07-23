# Export AWS credentials (assuming environment variables are already set)
$env:AWS_ACCESS_KEY_ID = $env:AWS_ACCESS_KEY_ID
$env:AWS_SECRET_ACCESS_KEY = $env:AWS_SECRET_ACCESS_KEY
$env:AWS_SESSION_TOKEN = $env:AWS_SESSION_TOKEN

# Navigate to Terraform directory
Set-Location -Path '../terraform'
terraform init
terraform apply -auto-approve

# Generate Ansible inventory
Set-Location -Path '../ansible'
& ./generate_inventory.sh

# Run Ansible playbook
ansible-playbook -i ./inventory/hosts.ini site.yml

# Configure kubectl with kubeconfig
echo "$env:KUBECONFIG_FILE_CONTENT" | Out-File -FilePath "$PWD\kubeconfig"
$env:KUBECONFIG = "$PWD\kubeconfig"

# Apply Kubernetes manifests
kubectl apply -f ../k8s-manifests/dev/app-deployment.yaml
kubectl apply -f ../k8s-manifests/dev/db-deployment.yaml
kubectl apply -f ../k8s-manifests/dev/memcache-deployment.yaml
kubectl apply -f ../k8s-manifests/dev/rabbitmq-deployment.yaml
kubectl apply -f ../k8s-manifests/dev/ingress.yaml