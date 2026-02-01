# Security Controls Documentation

## Overview

This document details the security controls implemented in the ICS Security Lab.

## Network Segmentation

### Firewall Rules Summary

#### Enterprise Zone
| Rule | Direction | Ports | Source | Purpose |
|------|-----------|-------|--------|---------|
| allow-ssh-external | INGRESS | 22 | Your IP | SSH access to jump host |
| allow-iap | INGRESS | 22 | 35.235.240.0/20 | GCP IAP tunnel |
| allow-icmp-internal | INGRESS | ICMP | 10.0.0.0/24 | Internal diagnostics |

#### Operations Zone
| Rule | Direction | Ports | Source | Purpose |
|------|-----------|-------|--------|---------|
| allow-ssh-from-enterprise | INGRESS | 22 | 10.0.0.0/24 | Admin access |
| allow-https-from-enterprise | INGRESS | 443, 8443 | 10.0.0.0/24 | Web UI access |
| allow-syslog-from-control | INGRESS | 514 | 10.2.0.0/24 | Log collection |
| allow-iap | INGRESS | 22 | 35.235.240.0/20 | GCP IAP tunnel |
| allow-icmp-from-control | INGRESS | ICMP | 10.2.0.0/24 | Diagnostics |

#### Control Zone
| Rule | Direction | Ports | Source | Purpose |
|------|-----------|-------|--------|---------|
| allow-ssh-from-operations | INGRESS | 22 | 10.1.0.0/24 | Admin access |
| allow-modbus-from-operations | INGRESS | 502 | 10.1.0.0/24 | OT protocol |
| allow-opcua-from-operations | INGRESS | 4840 | 10.1.0.0/24 | OT protocol |
| allow-icmp-from-operations | INGRESS | ICMP | 10.1.0.0/24 | Diagnostics |
| **deny-from-enterprise** | INGRESS | ALL | 10.0.0.0/24 | **Block direct access** |
| **deny-egress-internet** | EGRESS | ALL | 0.0.0.0/0 | **Air-gap** |

## Intrusion Detection System (IDS)

### Suricata Configuration

**Location:** Security Monitor (10.1.0.20)

**Custom Rules:**
```
# Detect Modbus Write Commands (Function Code 6)
alert tcp any any -> any 502 (msg:"OT ALERT: Unauthorized Modbus Write Command (FC 06)"; content:"|00 06 01 06|"; sid:1000002; rev:1;)

# Detect New Modbus Connections
alert tcp any any -> any 502 (msg:"OT ALERT: New Modbus Connection Initiated"; flags:S; sid:1000005; rev:1;)

# Detect Modbus Traffic on Port 502
alert tcp any any -> any 502 (msg:"OT ALERT: Modbus Traffic Detected (Port 502)"; sid:1000999; rev:1;)
```

## Logging & Monitoring

### Log Sources
| Source | Destination | Method |
|--------|-------------|--------|
| VPC Flow Logs | Cloud Logging | Automatic |
| Firewall Logs | Cloud Logging | Rule logging enabled |
| Suricata Alerts | /var/log/suricata/fast.log | Local + Cloud Agent |
| System Logs | Cloud Logging | Ops Agent |

### Alerts Configured
- Modbus write command detection
- New connection to OT protocols
- Denied traffic from Enterprise to Control
- Egress attempts from Control zone