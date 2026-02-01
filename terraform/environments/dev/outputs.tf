# =============================================================================
# Outputs - Important values after deployment
# =============================================================================

# -----------------------------------------------------------------------------
# Network Outputs
# -----------------------------------------------------------------------------
output "enterprise_vpc_name" {
  description = "Name of the Enterprise zone VPC"
  value       = module.network.enterprise_vpc_name
}

output "operations_vpc_name" {
  description = "Name of the Operations zone VPC"
  value       = module.network.operations_vpc_name
}

output "control_vpc_name" {
  description = "Name of the Control zone VPC"
  value       = module.network.control_vpc_name
}

# -----------------------------------------------------------------------------
# Compute Outputs
# -----------------------------------------------------------------------------
output "jump_host_external_ip" {
  description = "External IP of the jump host (use this to SSH in)"
  value       = module.compute.jump_host_external_ip
}

output "jump_host_internal_ip" {
  description = "Internal IP of the jump host"
  value       = module.compute.jump_host_internal_ip
}

output "historian_internal_ip" {
  description = "Internal IP of the historian server"
  value       = module.compute.historian_internal_ip
}

output "security_monitor_internal_ip" {
  description = "Internal IP of the security monitoring server"
  value       = module.compute.security_monitor_internal_ip
}

output "plc_simulator_internal_ip" {
  description = "Internal IP of the PLC simulator"
  value       = module.compute.plc_simulator_internal_ip
}

output "hmi_simulator_internal_ip" {
  description = "Internal IP of the HMI simulator"
  value       = module.compute.hmi_simulator_internal_ip
}

# -----------------------------------------------------------------------------
# Connection Instructions
# -----------------------------------------------------------------------------
output "ssh_command" {
  description = "Command to SSH to the jump host"
  value       = "gcloud compute ssh jump-host --zone=${var.zone} --project=${var.project_id}"
}

output "connection_instructions" {
  description = "How to connect to internal systems"
  value       = <<-EOT
    
    ====================================================================
    CONNECTION INSTRUCTIONS
    ====================================================================
    
    1. SSH to Jump Host (Enterprise Zone):
       gcloud compute ssh jump-host --zone=${var.zone}
    
    2. From Jump Host, SSH to Operations Zone:
       ssh 10.1.0.10  # Historian
       ssh 10.1.0.20  # Security Monitor
    
    3. From Operations Zone, SSH to Control Zone:
       ssh 10.2.0.10  # PLC Simulator
       ssh 10.2.0.20  # HMI Simulator
    
    NOTE: Direct SSH from Enterprise to Control is BLOCKED by design!
    This demonstrates proper network segmentation.
    
    ====================================================================
  EOT
}
