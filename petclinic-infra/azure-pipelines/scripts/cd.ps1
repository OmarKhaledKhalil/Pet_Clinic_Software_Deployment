#Write-Host "🚀 Starting Terraform Apply & Ansible Configuration..."

# Step 1: Terraform Apply
#Set-Location "./petclinic-infra"

#terraform init
#terraform apply -auto-approve

#Write-Host "✅ Infrastructure applied successfully."

# Step 2: Extract Public IPs (Optional)
#$tfOutput = terraform output -json
#$inventoryScriptPath = "./ansible/generate_inventory.sh"

#Write-Host "📋 Generating inventory from Terraform output..."
#bash $inventoryScriptPath

# Step 3: Run Ansible Playbook
#Set-Location "./ansible"

#ansible-playbook -i inventory/hosts.ini site.yml

#Write-Host "✅ Ansible configuration complete. Kubernetes should be ready!"
