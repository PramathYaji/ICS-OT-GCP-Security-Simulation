# =============================================================================
# Firewall Module Variables
# =============================================================================

variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "enterprise_network" {
  description = "Name of the Enterprise VPC"
  type        = string
}

variable "operations_network" {
  description = "Name of the Operations VPC"
  type        = string
}

variable "control_network" {
  description = "Name of the Control VPC"
  type        = string
}

variable "enterprise_cidr" {
  description = "CIDR range for Enterprise zone"
  type        = string
}

variable "operations_cidr" {
  description = "CIDR range for Operations zone"
  type        = string
}

variable "control_cidr" {
  description = "CIDR range for Control zone"
  type        = string
}

variable "allowed_ssh_cidr" {
  description = "CIDR range allowed for external SSH access"
  type        = string
}
