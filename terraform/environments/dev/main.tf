# =============================================================================
# ICS Security Lab - Main Terraform Configuration
# =============================================================================
# This configuration creates a Purdue Model-based network architecture on GCP
# for demonstrating OT/ICS security best practices.
#
# Architecture Overview:
# - Level 4/5 (Enterprise Zone): Corporate network with jump host
# - Level 3 (Operations Zone): DMZ with historian and security monitoring
# - Level 1/2 (Control Zone): Industrial control systems (PLC, HMI)
# =============================================================================

terraform {
  required_version = ">= 1.0.0"
  
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

# -----------------------------------------------------------------------------
# Provider Configuration
# -----------------------------------------------------------------------------
provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
}

# -----------------------------------------------------------------------------
# Network Module - Creates VPCs, Subnets, and VPC Peering
# -----------------------------------------------------------------------------
module "network" {
  source = "../../modules/network"
  
  project_id = var.project_id
  region     = var.region
  
  # Network CIDR ranges based on Purdue Model zones
  enterprise_cidr  = var.enterprise_cidr   # Level 4/5
  operations_cidr  = var.operations_cidr   # Level 3
  control_cidr     = var.control_cidr      # Level 1/2
}

# -----------------------------------------------------------------------------
# Firewall Module - Creates security rules between zones
# -----------------------------------------------------------------------------
module "firewall" {
  source = "../../modules/firewall"
  
  project_id = var.project_id
  
  # Pass network names from network module
  enterprise_network  = module.network.enterprise_vpc_name
  operations_network  = module.network.operations_vpc_name
  control_network     = module.network.control_vpc_name
  
  # Pass CIDR ranges for rule definitions
  enterprise_cidr  = var.enterprise_cidr
  operations_cidr  = var.operations_cidr
  control_cidr     = var.control_cidr
  
  # Your IP for SSH access (we'll set this)
  allowed_ssh_cidr = var.allowed_ssh_cidr
}

# -----------------------------------------------------------------------------
# Compute Module - Creates VMs in each zone
# -----------------------------------------------------------------------------
module "compute" {
  source = "../../modules/compute"
  
  project_id = var.project_id
  zone       = var.zone
  
  # Pass subnet self links from network module
  enterprise_subnet  = module.network.enterprise_subnet_self_link
  operations_subnet  = module.network.operations_subnet_self_link
  control_subnet     = module.network.control_subnet_self_link
  
  # VM configurations
  machine_type = var.machine_type
  
  # Tags for firewall rules
  enterprise_tags  = ["enterprise-zone", "jump-host"]
  operations_tags  = ["operations-zone", "historian", "security-monitor"]
  control_tags     = ["control-zone", "plc", "hmi"]
}
