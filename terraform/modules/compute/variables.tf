# =============================================================================
# Compute Module Variables
# =============================================================================

variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "zone" {
  description = "GCP Zone for compute instances"
  type        = string
}

variable "machine_type" {
  description = "Machine type for VMs"
  type        = string
  default     = "e2-micro"
}

variable "enterprise_subnet" {
  description = "Self link of the Enterprise subnet"
  type        = string
}

variable "operations_subnet" {
  description = "Self link of the Operations subnet"
  type        = string
}

variable "control_subnet" {
  description = "Self link of the Control subnet"
  type        = string
}

variable "enterprise_tags" {
  description = "Network tags for Enterprise zone VMs"
  type        = list(string)
  default     = ["enterprise-zone", "jump-host"]
}

variable "operations_tags" {
  description = "Network tags for Operations zone VMs"
  type        = list(string)
  default     = ["operations-zone"]
}

variable "control_tags" {
  description = "Network tags for Control zone VMs"
  type        = list(string)
  default     = ["control-zone"]
}
