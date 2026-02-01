# =============================================================================
# Firewall Module Outputs
# =============================================================================

output "enterprise_firewall_rules" {
  description = "List of firewall rules created for Enterprise zone"
  value = [
    google_compute_firewall.enterprise_allow_ssh_external.name,
    google_compute_firewall.enterprise_allow_icmp_internal.name,
    google_compute_firewall.enterprise_allow_iap.name,
  ]
}

output "operations_firewall_rules" {
  description = "List of firewall rules created for Operations zone"
  value = [
    google_compute_firewall.operations_allow_ssh_from_enterprise.name,
    google_compute_firewall.operations_allow_https_from_enterprise.name,
    google_compute_firewall.operations_allow_icmp_internal.name,
    google_compute_firewall.operations_allow_syslog_from_control.name,
  ]
}

output "control_firewall_rules" {
  description = "List of firewall rules created for Control zone"
  value = [
    google_compute_firewall.control_allow_ssh_from_operations.name,
    google_compute_firewall.control_allow_modbus_from_operations.name,
    google_compute_firewall.control_allow_opcua_from_operations.name,
    google_compute_firewall.control_allow_internal.name,
    google_compute_firewall.control_deny_from_enterprise.name,
    google_compute_firewall.control_deny_all_other.name,
  ]
}
