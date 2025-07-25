Test

🚀 Bet Clinic Infrastructure Configuration

This repository contains the Infrastructure-as-Code (IaC) configuration for deploying the Bet Clinic application on AWS. It uses Terraform for infrastructure provisioning and Ansible for post-deployment configuration, orchestrated via Azure DevOps Pipelines.

📦 Project Overview

Application: Bet Clinic (Deployed separately from the open-source GitHub repository)

Infrastructure Provider: AWS

CI/CD Platform: Azure DevOps Pipelines

IaC Tools:
Terraform: For provisioning resources like EC2 instances, VPC, Subnets, Security Groups, etc.
Ansible: For configuring Kubernetes on EC2 nodes

Cluster Design:
1 Master Node (Private Subnet)
2 Worker Nodes (Private Subnet)
1 Bastion Host (Public Subnet for SSH access)

Repositories:
App Code: GitHub - Bet Clinic App
Config Repo: This repository
📁 Repository Structure
text
├── ansible/
│   ├── group_vars/all.yml         # Global variables for Ansible
│   ├── generate_inventory.sh      # Generates dynamic inventory from Terraform output
│   ├── site.yml                   # Main playbook
│   └── roles/
│       ├── common/                # Common setup for all nodes
│       ├── master/                # Master node setup
│       └── worker/                # Worker node setup
├── terraform/
│   ├── main.tf                    # Main infrastructure definition
│   ├── variables.tf               # Input variables with descriptions
│   ├── outputs.tf                 # Terraform outputs (e.g., IPs)

⚙️ Azure DevOps Pipeline Overview

The infrastructure provisioning and configuration process is automated using Azure Pipelines, which includes:

Stages:

Terraform Init & Apply

Generate Inventory

Run Ansible Playbook

Each stage includes logging, state handling, and error checks.

🔐 Security Considerations

EC2 Key pairs and secrets are securely stored in Azure DevOps Library.

The Bastion host is the only public-facing machine.

Master and Worker nodes reside in private subnets.

📝 Usage
1. Clone the Repository:

git clone https://dev.azure.com/omarkhaledahmed/bet-clinic-config.git

2. Setup Backend (Optional):
Update backend configuration in main.tf to store state remotely if needed.

3. Run the Pipeline:
Trigger the Azure DevOps pipeline manually or on every push to main.

🧪 Testing
After deployment, validate the Kubernetes setup with:

kubectl get nodes

Use the Bastion host to securely access the internal cluster.

👨‍💻 Authors
Omar Khaled
Salma Walid
Mariam Hesham
This README provides a concise overview, ensuring clarity and ease of access for all contributors and users.
