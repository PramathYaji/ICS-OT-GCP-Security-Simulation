# =============================================================================
# Compute Module Outputs
# =============================================================================

# Jump Host
output "jump_host_external_ip" {
  description = "External IP of the jump host"
  value       = google_compute_instance.jump_host.network_interface[0].access_config[0].nat_ip
}

output "jump_host_internal_ip" {
  description = "Internal IP of the jump host"
  value       = google_compute_instance.jump_host.network_interface[0].network_ip
}

output "jump_host_name" {
  description = "Name of the jump host instance"
  value       = google_compute_instance.jump_host.name
}

# Historian
output "historian_internal_ip" {
  description = "Internal IP of the historian server"
  value       = google_compute_instance.historian.network_interface[0].network_ip
}

output "historian_name" {
  description = "Name of the historian instance"
  value       = google_compute_instance.historian.name
}

# Security Monitor
output "security_monitor_internal_ip" {
  description = "Internal IP of the security monitoring server"
  value       = google_compute_instance.security_monitor.network_interface[0].network_ip
}

output "security_monitor_name" {
  description = "Name of the security monitor instance"
  value       = google_compute_instance.security_monitor.name
}

# PLC Simulator
output "plc_simulator_internal_ip" {
  description = "Internal IP of the PLC simulator"
  value       = google_compute_instance.plc_simulator.network_interface[0].network_ip
}

output "plc_simulator_name" {
  description = "Name of the PLC simulator instance"
  value       = google_compute_instance.plc_simulator.name
}

# HMI Simulator
output "hmi_simulator_internal_ip" {
  description = "Internal IP of the HMI simulator"
  value       = google_compute_instance.hmi_simulator.network_interface[0].network_ip
}

output "hmi_simulator_name" {
  description = "Name of the HMI simulator instance"
  value       = google_compute_instance.hmi_simulator.name
}

# All instance names (for batch operations)
output "all_instance_names" {
  description = "List of all instance names"
  value = [
    google_compute_instance.jump_host.name,
    google_compute_instance.historian.name,
    google_compute_instance.security_monitor.name,
    google_compute_instance.plc_simulator.name,
    google_compute_instance.hmi_simulator.name,
  ]
}
