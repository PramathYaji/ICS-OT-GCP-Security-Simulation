# =============================================================================
# Network Module Outputs
# =============================================================================

# VPC Names
output "enterprise_vpc_name" {
  description = "Name of the Enterprise VPC"
  value       = google_compute_network.enterprise.name
}

output "operations_vpc_name" {
  description = "Name of the Operations VPC"
  value       = google_compute_network.operations.name
}

output "control_vpc_name" {
  description = "Name of the Control VPC"
  value       = google_compute_network.control.name
}

# VPC Self Links (for peering references)
output "enterprise_vpc_self_link" {
  description = "Self link of the Enterprise VPC"
  value       = google_compute_network.enterprise.self_link
}

output "operations_vpc_self_link" {
  description = "Self link of the Operations VPC"
  value       = google_compute_network.operations.self_link
}

output "control_vpc_self_link" {
  description = "Self link of the Control VPC"
  value       = google_compute_network.control.self_link
}

# Subnet Self Links (for VM attachments)
output "enterprise_subnet_self_link" {
  description = "Self link of the Enterprise subnet"
  value       = google_compute_subnetwork.enterprise.self_link
}

output "operations_subnet_self_link" {
  description = "Self link of the Operations subnet"
  value       = google_compute_subnetwork.operations.self_link
}

output "control_subnet_self_link" {
  description = "Self link of the Control subnet"
  value       = google_compute_subnetwork.control.self_link
}

# Subnet Names
output "enterprise_subnet_name" {
  description = "Name of the Enterprise subnet"
  value       = google_compute_subnetwork.enterprise.name
}

output "operations_subnet_name" {
  description = "Name of the Operations subnet"
  value       = google_compute_subnetwork.operations.name
}

output "control_subnet_name" {
  description = "Name of the Control subnet"
  value       = google_compute_subnetwork.control.name
}
