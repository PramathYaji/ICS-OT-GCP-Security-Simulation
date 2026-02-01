# =============================================================================
# Firewall Module - OT/ICS Security Rules
# =============================================================================
# Implements defense-in-depth firewall rules based on Purdue Model principles:
# - Strict ingress controls
# - Protocol-specific allowlists
# - Zone-based access control
# - Explicit deny rules for logging
# =============================================================================

# =============================================================================
# ENTERPRISE ZONE FIREWALL RULES
# =============================================================================

# -----------------------------------------------------------------------------
# Allow SSH to Jump Host from allowed IPs
# -----------------------------------------------------------------------------
resource "google_compute_firewall" "enterprise_allow_ssh_external" {
  name    = "enterprise-allow-ssh-external"
  network = var.enterprise_network
  project = var.project_id
  
  description = "Allow SSH access to jump host from allowed external IPs"
  direction   = "INGRESS"
  priority    = 1000
  
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  
  source_ranges = [var.allowed_ssh_cidr]
  target_tags   = ["jump-host"]
  
  log_config {
    metadata = "INCLUDE_ALL_METADATA"
  }
}

# -----------------------------------------------------------------------------
# Allow ICMP (ping) within Enterprise zone
# -----------------------------------------------------------------------------
resource "google_compute_firewall" "enterprise_allow_icmp_internal" {
  name    = "enterprise-allow-icmp-internal"
  network = var.enterprise_network
  project = var.project_id
  
  description = "Allow ICMP within Enterprise zone for diagnostics"
  direction   = "INGRESS"
  priority    = 1000
  
  allow {
    protocol = "icmp"
  }
  
  source_ranges = [var.enterprise_cidr]
  target_tags   = ["enterprise-zone"]
}

# -----------------------------------------------------------------------------
# Allow IAP (Identity-Aware Proxy) for secure SSH
# -----------------------------------------------------------------------------
resource "google_compute_firewall" "enterprise_allow_iap" {
  name    = "enterprise-allow-iap"
  network = var.enterprise_network
  project = var.project_id
  
  description = "Allow SSH via Identity-Aware Proxy (more secure than direct SSH)"
  direction   = "INGRESS"
  priority    = 1000
  
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  
  # IAP's IP range
  source_ranges = ["35.235.240.0/20"]
  target_tags   = ["jump-host"]
}

# =============================================================================
# OPERATIONS ZONE FIREWALL RULES
# =============================================================================

# -----------------------------------------------------------------------------
# Allow SSH from Enterprise Zone (Jump Host -> Operations)
# -----------------------------------------------------------------------------
resource "google_compute_firewall" "operations_allow_ssh_from_enterprise" {
  name    = "operations-allow-ssh-from-enterprise"
  network = var.operations_network
  project = var.project_id
  
  description = "Allow SSH from Enterprise zone to Operations zone"
  direction   = "INGRESS"
  priority    = 1000
  
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  
  source_ranges = [var.enterprise_cidr]
  target_tags   = ["operations-zone"]
  
  log_config {
    metadata = "INCLUDE_ALL_METADATA"
  }
}

# -----------------------------------------------------------------------------
# Allow HTTPS from Enterprise Zone (for web interfaces)
# -----------------------------------------------------------------------------
resource "google_compute_firewall" "operations_allow_https_from_enterprise" {
  name    = "operations-allow-https-from-enterprise"
  network = var.operations_network
  project = var.project_id
  
  description = "Allow HTTPS from Enterprise to Operations (historian web UI)"
  direction   = "INGRESS"
  priority    = 1000
  
  allow {
    protocol = "tcp"
    ports    = ["443", "8443"]
  }
  
  source_ranges = [var.enterprise_cidr]
  target_tags   = ["historian"]
  
  log_config {
    metadata = "INCLUDE_ALL_METADATA"
  }
}

# -----------------------------------------------------------------------------
# Allow ICMP within Operations zone
# -----------------------------------------------------------------------------
resource "google_compute_firewall" "operations_allow_icmp_internal" {
  name    = "operations-allow-icmp-internal"
  network = var.operations_network
  project = var.project_id
  
  description = "Allow ICMP within Operations zone"
  direction   = "INGRESS"
  priority    = 1000
  
  allow {
    protocol = "icmp"
  }
  
  source_ranges = [var.operations_cidr, var.enterprise_cidr]
  target_tags   = ["operations-zone"]
}

# -----------------------------------------------------------------------------
# Allow Syslog from Control Zone to Security Monitor
# -----------------------------------------------------------------------------
resource "google_compute_firewall" "operations_allow_syslog_from_control" {
  name    = "operations-allow-syslog-from-control"
  network = var.operations_network
  project = var.project_id
  
  description = "Allow syslog from Control zone to security monitoring"
  direction   = "INGRESS"
  priority    = 1000
  
  allow {
    protocol = "udp"
    ports    = ["514"]
  }
  
  allow {
    protocol = "tcp"
    ports    = ["514", "1514"]  # TCP syslog and syslog-ng
  }
  
  source_ranges = [var.control_cidr]
  target_tags   = ["security-monitor"]
  
  log_config {
    metadata = "INCLUDE_ALL_METADATA"
  }
}

# =============================================================================
# CONTROL ZONE FIREWALL RULES
# =============================================================================

# -----------------------------------------------------------------------------
# Allow SSH from Operations Zone ONLY (not from Enterprise!)
# -----------------------------------------------------------------------------
resource "google_compute_firewall" "control_allow_ssh_from_operations" {
  name    = "control-allow-ssh-from-operations"
  network = var.control_network
  project = var.project_id
  
  description = "Allow SSH from Operations zone to Control zone (NO direct Enterprise access)"
  direction   = "INGRESS"
  priority    = 1000
  
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  
  source_ranges = [var.operations_cidr]
  target_tags   = ["control-zone"]
  
  log_config {
    metadata = "INCLUDE_ALL_METADATA"
  }
}

# -----------------------------------------------------------------------------
# Allow Modbus/TCP from Operations Zone (Historian -> PLC)
# -----------------------------------------------------------------------------
resource "google_compute_firewall" "control_allow_modbus_from_operations" {
  name    = "control-allow-modbus-from-operations"
  network = var.control_network
  project = var.project_id
  
  description = "Allow Modbus/TCP (port 502) from Operations to Control zone"
  direction   = "INGRESS"
  priority    = 1000
  
  allow {
    protocol = "tcp"
    ports    = ["502"]
  }
  
  source_ranges = [var.operations_cidr]
  target_tags   = ["plc"]
  
  log_config {
    metadata = "INCLUDE_ALL_METADATA"
  }
}

# -----------------------------------------------------------------------------
# Allow OPC-UA from Operations Zone
# -----------------------------------------------------------------------------
resource "google_compute_firewall" "control_allow_opcua_from_operations" {
  name    = "control-allow-opcua-from-operations"
  network = var.control_network
  project = var.project_id
  
  description = "Allow OPC-UA (port 4840) from Operations to Control zone"
  direction   = "INGRESS"
  priority    = 1000
  
  allow {
    protocol = "tcp"
    ports    = ["4840"]
  }
  
  source_ranges = [var.operations_cidr]
  target_tags   = ["plc", "hmi"]
  
  log_config {
    metadata = "INCLUDE_ALL_METADATA"
  }
}

# -----------------------------------------------------------------------------
# Allow Internal Communication within Control Zone (PLC <-> HMI)
# -----------------------------------------------------------------------------
resource "google_compute_firewall" "control_allow_internal" {
  name    = "control-allow-internal"
  network = var.control_network
  project = var.project_id
  
  description = "Allow communication within Control zone (PLC <-> HMI)"
  direction   = "INGRESS"
  priority    = 1000
  
  allow {
    protocol = "tcp"
    ports    = ["502", "4840", "102"]  # Modbus, OPC-UA, S7comm
  }
  
  allow {
    protocol = "icmp"
  }
  
  source_ranges = [var.control_cidr]
  target_tags   = ["control-zone"]
}

# =============================================================================
# EXPLICIT DENY RULES (for logging blocked traffic)
# =============================================================================

# -----------------------------------------------------------------------------
# DENY Direct Enterprise -> Control (This is the key security control!)
# -----------------------------------------------------------------------------
resource "google_compute_firewall" "control_deny_from_enterprise" {
  name    = "control-deny-from-enterprise"
  network = var.control_network
  project = var.project_id
  
  description = "DENY all traffic directly from Enterprise to Control (Purdue Model enforcement)"
  direction   = "INGRESS"
  priority    = 900  # Higher priority than allows
  
  deny {
    protocol = "all"
  }
  
  source_ranges = [var.enterprise_cidr]
  target_tags   = ["control-zone"]
  
  log_config {
    metadata = "INCLUDE_ALL_METADATA"
  }
}

# -----------------------------------------------------------------------------
# Deny all other ingress to Control Zone (catch-all)
# -----------------------------------------------------------------------------
resource "google_compute_firewall" "control_deny_all_other" {
  name    = "control-deny-all-other"
  network = var.control_network
  project = var.project_id
  
  description = "Deny all other traffic to Control zone (default deny)"
  direction   = "INGRESS"
  priority    = 65534  # Just before implicit deny
  
  deny {
    protocol = "all"
  }
  
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["control-zone"]
  
  log_config {
    metadata = "INCLUDE_ALL_METADATA"
  }
}

# =============================================================================
# EGRESS RULES (Control what can leave each zone)
# =============================================================================

# -----------------------------------------------------------------------------
# Control Zone: Only allow egress to Operations Zone
# -----------------------------------------------------------------------------
resource "google_compute_firewall" "control_allow_egress_to_operations" {
  name    = "control-allow-egress-to-operations"
  network = var.control_network
  project = var.project_id
  
  description = "Allow egress from Control zone only to Operations zone"
  direction   = "EGRESS"
  priority    = 1000
  
  allow {
    protocol = "tcp"
    ports    = ["514", "1514", "443"]  # Syslog and HTTPS
  }
  
  allow {
    protocol = "udp"
    ports    = ["514"]  # UDP syslog
  }
  
  allow {
    protocol = "icmp"
  }
  
  destination_ranges = [var.operations_cidr]
  target_tags        = ["control-zone"]
}

# -----------------------------------------------------------------------------
# Control Zone: Allow internal egress
# -----------------------------------------------------------------------------
resource "google_compute_firewall" "control_allow_egress_internal" {
  name    = "control-allow-egress-internal"
  network = var.control_network
  project = var.project_id
  
  description = "Allow egress within Control zone"
  direction   = "EGRESS"
  priority    = 1000
  
  allow {
    protocol = "all"
  }
  
  destination_ranges = [var.control_cidr]
  target_tags        = ["control-zone"]
}

# -----------------------------------------------------------------------------
# Control Zone: Deny egress to internet (air-gap simulation)
# -----------------------------------------------------------------------------
resource "google_compute_firewall" "control_deny_egress_internet" {
  name    = "control-deny-egress-internet"
  network = var.control_network
  project = var.project_id
  
  description = "Deny internet egress from Control zone (air-gap simulation)"
  direction   = "EGRESS"
  priority    = 65534
  
  deny {
    protocol = "all"
  }
  
  destination_ranges = ["0.0.0.0/0"]
  target_tags        = ["control-zone"]
  
  log_config {
    metadata = "INCLUDE_ALL_METADATA"
  }
}
