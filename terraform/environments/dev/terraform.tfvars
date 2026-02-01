# =============================================================================
# Terraform Variables - EDIT THESE VALUES
# =============================================================================
# Copy this file to terraform.tfvars and update with your values
# DO NOT commit terraform.tfvars to git (it may contain sensitive data)
# =============================================================================

# Your GCP Project ID (REQUIRED - replace with your actual project ID)
project_id = "oticsproject-486001"

# Region and Zone (us-central1 has good free tier availability)
region = "us-central1"
zone   = "us-central1-a"

# Network CIDR ranges (defaults are fine, but you can customize)
enterprise_cidr = "10.0.0.0/24"   # Level 4/5: Enterprise/Corporate
operations_cidr = "10.1.0.0/24"   # Level 3: Operations/DMZ
control_cidr    = "10.2.0.0/24"   # Level 1/2: Control Systems

# SSH Access - IMPORTANT: Replace with your IP for security
# Find your IP at: https://whatismyipaddress.com/
# Format: "YOUR_IP/32" (e.g., "203.0.113.50/32")
# Using 0.0.0.0/0 allows SSH from anywhere (less secure, ok for learning)
allowed_ssh_cidr = "0.0.0.0/0"

# VM Machine Type (e2-micro is free tier eligible for 1 instance)
# We'll use e2-micro for all to minimize costs
machine_type = "e2-micro"
