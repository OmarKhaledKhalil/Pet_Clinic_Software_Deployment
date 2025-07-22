# 🚀 Bet Clinic Infrastructure Configuration

This repository contains the full Infrastructure-as-Code (IaC) configuration used to provision and configure the AWS environment for the **Bet Clinic** application. We use **Terraform** for infrastructure provisioning and **Ansible** for post-deployment configuration, all orchestrated through **Azure DevOps Pipelines**.

---

## 📦 Project Overview

- **Application:** Bet Clinic (Deployed separately from Open Source GitHub Repo)
- **Infrastructure Provider:** AWS
- **CI/CD Platform:** Azure DevOps Pipelines
- **IaC Tools:**
  - `Terraform` — To provision EC2 instances, VPC, Subnets, Security Groups, etc.
  - `Ansible` — To configure Kubernetes on EC2 nodes
- **Cluster Design:** 
  - 1 Master Node (Private Subnet)
  - 2 Worker Nodes (Private Subnet)
  - 1 Bastion Host (Public Subnet for SSH access)
- **Repositories:**
  - App Code: [GitHub - Bet Clinic App](#)
  - Config Repo: (this repository)

---

## 📁 Repository Structure

├── ansible/
│ ├── group_vars/all.yml # Global vars for Ansible
│ ├── generate_inventory.sh # Builds dynamic inventory from Terraform output
│ ├── site.yml # Main playbook
│ └── roles/
│ ├── common/ # Common setup for all nodes
│ ├── master/ # Master node setup
│ └── worker/ # Worker node setup
├── terraform/
│ ├── main.tf # Main infrastructure definition
│ ├── variables.tf # Input variables with descriptions
│ ├── outputs.tf # Terraform outputs (e.g., IPs)


---

## ⚙️ Azure DevOps Pipeline Overview

> The entire infrastructure provisioning and configuration process is automated using Azure Pipelines.

### Stages:
1. **Terraform Init & Apply**
2. **Generate Inventory**
3. **Run Ansible Playbook**

Each stage includes appropriate logging, state handling, and error checks.

---

## 🔐 Security Considerations

- EC2 Key pairs and secrets are securely stored in Azure DevOps Library.
- Bastion host is the only public-facing machine.
- Master/Worker nodes reside in private subnets.

---

## 📝 Usage

### 1. Clone the Repo:
```bash
git clone https://dev.azure.com/<your-org>/bet-clinic-config.git
2. Setup Backend (Optional):
Update backend config in main.tf to store state remotely if needed.

3. Run Pipeline
Trigger the Azure DevOps pipeline manually or on every push to main.

🧪 Testing
After deployment, validate Kubernetes setup with:

kubectl get nodes
Use the bastion host to securely access the internal cluster.

👨‍💻 Authors
Omar Khaled

Salma Walid 

Mariam Hesham

