# Write-Host "📦 Starting Terraform CI Stage..."           # Output start message to console

# Navigate to infrastructure directory
# Set-Location "./petclinic-infra"                         # Change directory to Terraform config folder

# Init Terraform
# terraform init                                           # Initialize Terraform (download providers, setup backend)

# Validate syntax
# terraform validate                                       # Validate Terraform files syntax

# Generate plan
# terraform plan -out=tfplan                               # Create an execution plan and save it as tfplan file

# Write-Host "✅ Terraform Plan Complete."                 # Output success message to console