# =============================================================================
# Compute Module - Virtual Machines for Each Zone
# =============================================================================
# Creates VMs representing systems in each Purdue Model zone:
# - Enterprise: Jump Host (bastion)
# - Operations: Historian Server, Security Monitoring
# - Control: PLC Simulator, HMI Simulator
# =============================================================================

# -----------------------------------------------------------------------------
# ENTERPRISE ZONE: Jump Host (Bastion)
# -----------------------------------------------------------------------------
# This is your entry point into the lab. All access to lower zones
# must go through this jump host, simulating a proper bastion architecture.

resource "google_compute_instance" "jump_host" {
  name         = "jump-host"
  machine_type = var.machine_type
  zone         = var.zone
  project      = var.project_id
  
  description = "Jump Host / Bastion - Entry point to ICS Security Lab"
  
  tags = var.enterprise_tags
  
  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-12"
      size  = 10
      type  = "pd-standard"
    }
  }
  
  network_interface {
    subnetwork = var.enterprise_subnet
    
    # External IP for SSH access
    access_config {
      // Ephemeral public IP
    }
  }
  
  # Startup script to configure the jump host
  metadata_startup_script = <<-EOF
    #!/bin/bash
    apt-get update
    apt-get install -y curl wget net-tools dnsutils tcpdump nmap
    
    # Create a banner
    cat > /etc/motd << 'BANNER'
    ╔═══════════════════════════════════════════════════════════════════╗
    ║           ICS SECURITY LAB - JUMP HOST                            ║
    ║           Purdue Level 4/5 - Enterprise Zone                      ║
    ╠═══════════════════════════════════════════════════════════════════╣
    ║  From here you can access:                                        ║
    ║  • Operations Zone (10.1.0.0/24):                                 ║
    ║    - Historian: 10.1.0.10                                         ║
    ║    - Security Monitor: 10.1.0.20                                  ║
    ║                                                                   ║
    ║  WARNING: Direct access to Control Zone is BLOCKED by design!    ║
    ╚═══════════════════════════════════════════════════════════════════╝
    BANNER
    
    echo "Jump host setup complete" > /var/log/startup-complete.log
  EOF
  
  # Ensure we can SSH via metadata
  metadata = {
    enable-oslogin = "FALSE"
  }
  
  # Allow the instance to be stopped for cost savings
  scheduling {
    preemptible       = false
    automatic_restart = true
  }
  
  # Service account with minimal permissions
  service_account {
    scopes = ["cloud-platform"]
  }
  
  labels = {
    environment = "dev"
    zone        = "enterprise"
    role        = "jump-host"
    project     = "ics-security-lab"
  }
}

# -----------------------------------------------------------------------------
# OPERATIONS ZONE: Historian Server
# -----------------------------------------------------------------------------
# Simulates an industrial historian that collects data from control systems.
# In real environments, this would run software like OSIsoft PI or Wonderware.

resource "google_compute_instance" "historian" {
  name         = "historian-server"
  machine_type = var.machine_type
  zone         = var.zone
  project      = var.project_id
  
  description = "Historian Server - Purdue Level 3 (Operations Zone)"
  
  tags = var.operations_tags
  
  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-12"
      size  = 10
      type  = "pd-standard"
    }
  }
  
  network_interface {
    subnetwork = var.operations_subnet
    network_ip = "10.1.0.10"
    
    # No external IP - only accessible via jump host
  }
  
  metadata_startup_script = <<-EOF
    #!/bin/bash
    apt-get update
    apt-get install -y curl wget net-tools tcpdump python3 python3-pip
    
    cat > /etc/motd << 'BANNER'
    ╔═══════════════════════════════════════════════════════════════════╗
    ║           HISTORIAN SERVER                                        ║
    ║           Purdue Level 3 - Operations Zone (DMZ)                  ║
    ╠═══════════════════════════════════════════════════════════════════╣
    ║  This server collects data from Control Zone systems.             ║
    ║  • Can communicate with PLC (10.2.0.10) via Modbus TCP/502        ║
    ║  • Can communicate with HMI (10.2.0.20) via OPC-UA/4840          ║
    ╚═══════════════════════════════════════════════════════════════════╝
    BANNER
    
    echo "Historian setup complete" > /var/log/startup-complete.log
  EOF
  
  metadata = {
    enable-oslogin = "FALSE"
  }
  
  service_account {
    scopes = ["cloud-platform"]
  }
  
  labels = {
    environment = "dev"
    zone        = "operations"
    role        = "historian"
    project     = "ics-security-lab"
  }
}

# -----------------------------------------------------------------------------
# OPERATIONS ZONE: Security Monitoring Server
# -----------------------------------------------------------------------------
# This will run Suricata IDS and log aggregation for security monitoring.

resource "google_compute_instance" "security_monitor" {
  name         = "security-monitor"
  machine_type = var.machine_type
  zone         = var.zone
  project      = var.project_id
  
  description = "Security Monitoring Server - Purdue Level 3 (Operations Zone)"
  
  tags = var.operations_tags
  
  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-12"
      size  = 20  # Larger disk for logs
      type  = "pd-standard"
    }
  }
  
  network_interface {
    subnetwork = var.operations_subnet
    network_ip = "10.1.0.20"
    
    # No external IP
  }
  
  metadata_startup_script = <<-EOF
    #!/bin/bash
    apt-get update
    apt-get install -y curl wget net-tools tcpdump rsyslog
    
    # Configure rsyslog to receive logs from Control zone
    cat >> /etc/rsyslog.conf << 'SYSLOG'
    # Receive syslog from Control Zone
    module(load="imudp")
    input(type="imudp" port="514")
    module(load="imtcp")
    input(type="imtcp" port="514")
    SYSLOG
    
    systemctl restart rsyslog
    
    cat > /etc/motd << 'BANNER'
    ╔═══════════════════════════════════════════════════════════════════╗
    ║           SECURITY MONITORING SERVER                              ║
    ║           Purdue Level 3 - Operations Zone (DMZ)                  ║
    ╠═══════════════════════════════════════════════════════════════════╣
    ║  This server provides:                                            ║
    ║  • Network IDS (Suricata - to be installed)                      ║
    ║  • Log aggregation from Control Zone                              ║
    ║  • Security alerting                                              ║
    ╚═══════════════════════════════════════════════════════════════════╝
    BANNER
    
    echo "Security Monitor setup complete" > /var/log/startup-complete.log
  EOF
  
  metadata = {
    enable-oslogin = "FALSE"
  }
  
  service_account {
    scopes = ["cloud-platform"]
  }
  
  labels = {
    environment = "dev"
    zone        = "operations"
    role        = "security-monitor"
    project     = "ics-security-lab"
  }
}

# -----------------------------------------------------------------------------
# CONTROL ZONE: PLC Simulator
# -----------------------------------------------------------------------------
# Simulates a Programmable Logic Controller (PLC).
# Will run OpenPLC or similar to simulate industrial control.

resource "google_compute_instance" "plc_simulator" {
  name         = "plc-simulator"
  machine_type = var.machine_type
  zone         = var.zone
  project      = var.project_id
  
  description = "PLC Simulator - Purdue Level 1/2 (Control Zone)"
  
  tags = var.control_tags
  
  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-12"
      size  = 10
      type  = "pd-standard"
    }
  }
  
  network_interface {
    subnetwork = var.control_subnet
    network_ip = "10.2.0.10"
    
    # NO external IP - completely isolated!
  }
  
  metadata_startup_script = <<-EOF
    #!/bin/bash
    apt-get update
    apt-get install -y curl wget net-tools python3 python3-pip
    
    cat > /etc/motd << 'BANNER'
    ╔═══════════════════════════════════════════════════════════════════╗
    ║           PLC SIMULATOR                                           ║
    ║           Purdue Level 1/2 - Control Zone                        ║
    ╠═══════════════════════════════════════════════════════════════════╣
    ║  This system simulates a Programmable Logic Controller.           ║
    ║  • Modbus TCP server on port 502                                  ║
    ║  • Only accessible from Operations Zone                           ║
    ║  • NO direct access from Enterprise Zone (air-gapped)            ║
    ╚═══════════════════════════════════════════════════════════════════╝
    BANNER
    
    # Configure syslog to send to Security Monitor
    echo "*.* @10.1.0.20:514" >> /etc/rsyslog.conf
    systemctl restart rsyslog
    
    echo "PLC Simulator setup complete" > /var/log/startup-complete.log
  EOF
  
  metadata = {
    enable-oslogin = "FALSE"
  }
  
  service_account {
    scopes = ["logging-write", "monitoring-write"]
  }
  
  labels = {
    environment = "dev"
    zone        = "control"
    role        = "plc"
    project     = "ics-security-lab"
  }
}

# -----------------------------------------------------------------------------
# CONTROL ZONE: HMI Simulator
# -----------------------------------------------------------------------------
# Simulates a Human-Machine Interface for operator interaction.

resource "google_compute_instance" "hmi_simulator" {
  name         = "hmi-simulator"
  machine_type = var.machine_type
  zone         = var.zone
  project      = var.project_id
  
  description = "HMI Simulator - Purdue Level 2 (Control Zone)"
  
  tags = var.control_tags
  
  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-12"
      size  = 10
      type  = "pd-standard"
    }
  }
  
  network_interface {
    subnetwork = var.control_subnet
    network_ip = "10.2.0.20"
    
    # NO external IP
  }
  
  metadata_startup_script = <<-EOF
    #!/bin/bash
    apt-get update
    apt-get install -y curl wget net-tools python3 python3-pip
    
    cat > /etc/motd << 'BANNER'
    ╔═══════════════════════════════════════════════════════════════════╗
    ║           HMI SIMULATOR                                           ║
    ║           Purdue Level 2 - Control Zone                          ║
    ╠═══════════════════════════════════════════════════════════════════╣
    ║  This system simulates a Human-Machine Interface.                 ║
    ║  • Communicates with PLC at 10.2.0.10                            ║
    ║  • Only accessible from Operations Zone                           ║
    ║  • NO direct access from Enterprise Zone                          ║
    ╚═══════════════════════════════════════════════════════════════════╝
    BANNER
    
    # Configure syslog to send to Security Monitor
    echo "*.* @10.1.0.20:514" >> /etc/rsyslog.conf
    systemctl restart rsyslog
    
    echo "HMI Simulator setup complete" > /var/log/startup-complete.log
  EOF
  
  metadata = {
    enable-oslogin = "FALSE"
  }
  
  service_account {
    scopes = ["logging-write", "monitoring-write"]
  }
  
  labels = {
    environment = "dev"
    zone        = "control"
    role        = "hmi"
    project     = "ics-security-lab"
  }
}
