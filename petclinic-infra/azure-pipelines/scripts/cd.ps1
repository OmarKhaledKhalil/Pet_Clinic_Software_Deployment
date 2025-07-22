# Navigate to Terraform directory
Set-Location -Path '../terraform'              # Change directory to where Terraform files are located

# Initialize and apply Terraform configuration
terraform init                                # Initialize Terraform configuration
terraform apply -auto-approve                 # Apply Terraform changes automatically without prompt

# Generate Ansible inventory
Set-Location -Path '../ansible'               # Change directory to where Ansible files are located
& ./generate_inventory.sh                     # Execute the script to generate Ansible inventory

# Run Ansible playbook
ansible-playbook -i ./inventory/hosts.ini site.yml # Run Ansible playbook using the generated inventory