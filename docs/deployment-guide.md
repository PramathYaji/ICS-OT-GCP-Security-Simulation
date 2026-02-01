# Deployment Guide

## Prerequisites

- Google Cloud Platform account with billing enabled
- Terraform >= 1.0.0
- Google Cloud CLI (gcloud)
- $300 GCP free credits (sufficient for this lab)

## Quick Start

### 1. Clone the Repository
```bash
git clone https://github.com/YOUR_USERNAME/ics-security-lab.git
cd ics-security-lab
```

### 2. Configure GCP
```bash
# Login to GCP
gcloud auth login

# Set your project
gcloud config set project YOUR_PROJECT_ID

# Enable required APIs
gcloud services enable compute.googleapis.com
gcloud services enable cloudresourcemanager.googleapis.com
gcloud services enable logging.googleapis.com

# Create application default credentials
gcloud auth application-default login
```

### 3. Configure Terraform Variables
```bash
cd terraform/environments/dev
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars`:
```hcl
project_id = "your-project-id"
region     = "us-central1"
zone       = "us-central1-a"
```

### 4. Deploy Infrastructure
```bash
terraform init
terraform plan
terraform apply
```

### 5. Verify Deployment
```bash
# SSH to jump host
gcloud compute ssh jump-host --zone=us-central1-a

# Test connectivity to Operations zone
ping 10.1.0.10 -c 3

# Verify Control zone is blocked
ping 10.2.0.10 -c 3  # Should fail
```

## Post-Deployment Setup

### Install OT Simulators

The PLC and HMI simulators require manual software installation due to air-gap configuration. See [OT Simulator Setup](ot-simulator-setup.md) for details.

### Configure Suricata IDS

SSH to Security Monitor and install Suricata:
```bash
gcloud compute ssh security-monitor --zone=us-central1-a --tunnel-through-iap
sudo apt-get update && sudo apt-get install -y suricata
```

## Cost Management

### Stop VMs When Not in Use
```bash
gcloud compute instances stop jump-host historian-server security-monitor plc-simulator hmi-simulator --zone=us-central1-a
```

### Start VMs
```bash
gcloud compute instances start jump-host historian-server security-monitor plc-simulator hmi-simulator --zone=us-central1-a
```

### Destroy Everything
```bash
cd terraform/environments/dev
terraform destroy
```

## Estimated Costs

| Resource | Monthly Cost (24/7) | With Stop/Start |
|----------|--------------------:|----------------:|
| 5x e2-micro VMs | ~$25 | ~$5 |
| VPC/Networking | $0 | $0 |
| Storage (50GB) | ~$2 | ~$2 |
| **Total** | **~$27** | **~$7** |