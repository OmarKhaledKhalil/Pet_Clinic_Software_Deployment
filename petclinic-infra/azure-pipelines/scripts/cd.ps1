try {
    # Export AWS credentials for Terraform
    Write-Host "Exporting AWS credentials..."
    $env:AWS_ACCESS_KEY_ID = $env:AWS_ACCESS_KEY_ID
    $env:AWS_SECRET_ACCESS_KEY = $env:AWS_SECRET_ACCESS_KEY
    $env:AWS_SESSION_TOKEN = $env:AWS_SESSION_TOKEN

    # Navigate to Terraform directory to set up infrastructure
    Write-Host "Navigating to Terraform directory..."
    Set-Location -Path '../terraform'
    terraform init
    terraform apply -auto-approve

    # Generate Ansible inventory for server provisioning
    Write-Host "Generating Ansible inventory..."
    Set-Location -Path '../ansible'
    & ./generate_inventory.sh

    # Run Ansible playbook to configure servers
    Write-Host "Running Ansible playbook..."
    ansible-playbook -i ./inventory/hosts.ini site.yml

    # Set up Kubernetes configuration
    Write-Host "Configuring kubectl..."
    echo "$env:KUBECONFIG_FILE_CONTENT" | Out-File -FilePath "$PWD\kubeconfig"
    $env:KUBECONFIG = "$PWD\kubeconfig"

    # Apply Kubernetes manifests for deployment
    Write-Host "Applying Kubernetes manifests in the correct order..."
    kubectl apply -f ../k8s-manifests/dev/db-deployment.yaml  # Deploy DB first
    kubectl apply -f ../k8s-manifests/dev/memcache-deployment.yaml  # Deploy Cache
    kubectl apply -f ../k8s-manifests/dev/rabbitmq-deployment.yaml  # Deploy RabbitMQ
    kubectl apply -f ../k8s-manifests/dev/ingress.yaml  # Deploy Ingress
    kubectl apply -f ../k8s-manifests/dev/app-deployment.yaml  # Deploy Application
} catch {
    Write-Error "Deployment script failed: $_"
    exit 1
}