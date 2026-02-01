# =============================================================================
# Network Module - Purdue Model Network Architecture
# =============================================================================
# Creates three VPCs representing Purdue Model zones:
# - Enterprise VPC (Level 4/5): Corporate/Business network
# - Operations VPC (Level 3): DMZ between IT and OT
# - Control VPC (Level 1/2): Industrial control systems
#
# VPC Peering is configured to allow controlled communication between zones
# =============================================================================

# -----------------------------------------------------------------------------
# ENTERPRISE VPC (Purdue Level 4/5)
# -----------------------------------------------------------------------------
# This represents the corporate IT network where business systems reside.
# Contains the jump host (bastion) for secure access to lower zones.

resource "google_compute_network" "enterprise" {
  name                    = "enterprise-vpc"
  project                 = var.project_id
  auto_create_subnetworks = false
  description             = "Enterprise Zone - Purdue Level 4/5 (Corporate Network)"
}

resource "google_compute_subnetwork" "enterprise" {
  name          = "enterprise-subnet"
  project       = var.project_id
  ip_cidr_range = var.enterprise_cidr
  region        = var.region
  network       = google_compute_network.enterprise.id
  description   = "Enterprise subnet for corporate systems and jump host"
  
  # Enable flow logs for security monitoring
  log_config {
    aggregation_interval = "INTERVAL_5_SEC"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }
}

# -----------------------------------------------------------------------------
# OPERATIONS VPC (Purdue Level 3)
# -----------------------------------------------------------------------------
# This is the DMZ between IT and OT networks.
# Contains historian servers, security monitoring, and other shared services.

resource "google_compute_network" "operations" {
  name                    = "operations-vpc"
  project                 = var.project_id
  auto_create_subnetworks = false
  description             = "Operations Zone - Purdue Level 3 (DMZ)"
}

resource "google_compute_subnetwork" "operations" {
  name          = "operations-subnet"
  project       = var.project_id
  ip_cidr_range = var.operations_cidr
  region        = var.region
  network       = google_compute_network.operations.id
  description   = "Operations subnet for historian and security monitoring"
  
  # Enable flow logs for security monitoring
  log_config {
    aggregation_interval = "INTERVAL_5_SEC"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }
}

# -----------------------------------------------------------------------------
# CONTROL VPC (Purdue Level 1/2)
# -----------------------------------------------------------------------------
# This is the industrial control network.
# Contains PLCs, HMIs, and other control system devices.
# Should be the most isolated and protected zone.

resource "google_compute_network" "control" {
  name                    = "control-vpc"
  project                 = var.project_id
  auto_create_subnetworks = false
  description             = "Control Zone - Purdue Level 1/2 (Industrial Control Systems)"
}

resource "google_compute_subnetwork" "control" {
  name          = "control-subnet"
  project       = var.project_id
  ip_cidr_range = var.control_cidr
  region        = var.region
  network       = google_compute_network.control.id
  description   = "Control subnet for PLC and HMI systems"
  
  # Enable flow logs for security monitoring
  log_config {
    aggregation_interval = "INTERVAL_5_SEC"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }
}

# -----------------------------------------------------------------------------
# VPC PEERING: Enterprise <-> Operations
# -----------------------------------------------------------------------------
# Allows communication between Enterprise and Operations zones.
# Traffic is still controlled by firewall rules.

resource "google_compute_network_peering" "enterprise_to_operations" {
  name         = "enterprise-to-operations"
  network      = google_compute_network.enterprise.self_link
  peer_network = google_compute_network.operations.self_link
  
  # Export custom routes so Enterprise can reach Operations
  export_custom_routes = true
  import_custom_routes = true
}

resource "google_compute_network_peering" "operations_to_enterprise" {
  name         = "operations-to-enterprise"
  network      = google_compute_network.operations.self_link
  peer_network = google_compute_network.enterprise.self_link
  
  export_custom_routes = true
  import_custom_routes = true
  
  # Ensure this is created after the first peering
  depends_on = [google_compute_network_peering.enterprise_to_operations]
}

# -----------------------------------------------------------------------------
# VPC PEERING: Operations <-> Control
# -----------------------------------------------------------------------------
# Allows communication between Operations and Control zones.
# This is the ONLY path to reach the Control zone.
# Direct Enterprise -> Control is NOT allowed (no peering).

resource "google_compute_network_peering" "operations_to_control" {
  name         = "operations-to-control"
  network      = google_compute_network.operations.self_link
  peer_network = google_compute_network.control.self_link
  
  export_custom_routes = true
  import_custom_routes = true
}

resource "google_compute_network_peering" "control_to_operations" {
  name         = "control-to-operations"
  network      = google_compute_network.control.self_link
  peer_network = google_compute_network.operations.self_link
  
  export_custom_routes = true
  import_custom_routes = true
  
  depends_on = [google_compute_network_peering.operations_to_control]
}

# -----------------------------------------------------------------------------
# NOTE: NO PEERING between Enterprise and Control
# -----------------------------------------------------------------------------
# This is intentional! The Purdue Model requires that corporate systems
# cannot directly access control systems. All traffic must go through
# the Operations zone (DMZ), where it can be inspected and controlled.
