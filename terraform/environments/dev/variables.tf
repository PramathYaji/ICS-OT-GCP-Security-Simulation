# =============================================================================
# Variables for ICS Security Lab
# =============================================================================

# -----------------------------------------------------------------------------
# GCP Project Configuration
# -----------------------------------------------------------------------------
variable "project_id" {
  description = "The GCP project ID where resources will be created"
  type        = string
}

variable "region" {
  description = "The GCP region for resources"
  type        = string
  default     = "us-central1"
}

variable "zone" {
  description = "The GCP zone for compute resources"
  type        = string
  default     = "us-central1-a"
}

# -----------------------------------------------------------------------------
# Network CIDR Ranges (Purdue Model Zones)
# -----------------------------------------------------------------------------
variable "enterprise_cidr" {
  description = "CIDR range for Enterprise Zone (Purdue Level 4/5)"
  type        = string
  default     = "10.0.0.0/24"
}

variable "operations_cidr" {
  description = "CIDR range for Operations Zone (Purdue Level 3 - DMZ)"
  type        = string
  default     = "10.1.0.0/24"
}

variable "control_cidr" {
  description = "CIDR range for Control Zone (Purdue Level 1/2)"
  type        = string
  default     = "10.2.0.0/24"
}

# -----------------------------------------------------------------------------
# Security Configuration
# -----------------------------------------------------------------------------
variable "allowed_ssh_cidr" {
  description = "CIDR range allowed to SSH to jump host (your IP/32 or 0.0.0.0/0 for testing)"
  type        = string
  default     = "0.0.0.0/0"  # CHANGE THIS to your IP for production!
}

# -----------------------------------------------------------------------------
# Compute Configuration
# -----------------------------------------------------------------------------
variable "machine_type" {
  description = "Machine type for VMs (e2-micro is free tier eligible)"
  type        = string
  default     = "e2-micro"
}
