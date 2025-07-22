# Write-Host "🚀 Starting Terraform Apply & Ansible Configuration..."  # Output start message for deployment stage

# Step 1: Terraform Apply
# Set-Location "./petclinic-infra"                                     # Change directory to Terraform config folder

# terraform init                                                      # Initialize Terraform (ensures plugins and backend configured)
# terraform apply -auto-approve                                       # Apply Terraform plan without interactive approval

# Write-Host "✅ Infrastructure applied successfully."                # Output success message after infra deploy

# Step 2: Extract Public IPs (Optional)
# $tfOutput = terraform output -json                                  # Get Terraform outputs in JSON format (can be used to feed Ansible)
# $inventoryScriptPath = "./ansible/generate_inventory.sh"            # Path to inventory generation script

# Write-Host "📋 Generating inventory from Terraform output..."       # Message before generating inventory
# bash $inventoryScriptPath                                           # Execute the script to generate Ansible inventory

# Step 3: Run Ansible Playbook
# Set-Location "./ansible"                                            # Change directory to Ansible folder

# ansible-playbook -i inventory/hosts.ini site.yml                    # Run Ansible playbook with generated inventory

# Write-Host "✅ Ansible configuration complete. Kubernetes should be ready!"  # Final success message
