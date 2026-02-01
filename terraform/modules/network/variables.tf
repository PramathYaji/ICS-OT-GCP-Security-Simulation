# =============================================================================
# Network Module Variables
# =============================================================================

variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "region" {
  description = "GCP Region for subnets"
  type        = string
}

variable "enterprise_cidr" {
  description = "CIDR range for Enterprise Zone"
  type        = string
}

variable "operations_cidr" {
  description = "CIDR range for Operations Zone"
  type        = string
}

variable "control_cidr" {
  description = "CIDR range for Control Zone"
  type        = string
}
