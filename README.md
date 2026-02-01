# 🏭 ICS Security Lab

> A comprehensive OT/ICS (Operational Technology / Industrial Control Systems) security lab built on Google Cloud Platform, demonstrating enterprise-grade security practices based on the **Purdue Model** architecture.

[![Terraform](https://img.shields.io/badge/Terraform-1.0+-purple.svg)](https://www.terraform.io/)
[![GCP](https://img.shields.io/badge/GCP-Cloud-blue.svg)](https://cloud.google.com/)
[![Suricata](https://img.shields.io/badge/Suricata-IDS-orange.svg)](https://suricata.io/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

## 🎯 Project Overview

This project creates a **simulated industrial control environment** to demonstrate:

- ✅ **Network Segmentation** - Purdue Model implementation with 3 security zones
- ✅ **Defense in Depth** - Multiple layers of security controls
- ✅ **OT Protocol Security** - Modbus TCP monitoring and protection
- ✅ **Intrusion Detection** - Suricata IDS with custom OT rules
- ✅ **Attack Simulation** - Red team scenarios with detection validation

## 🏗️ Architecture
```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                              PURDUE MODEL IMPLEMENTATION                         │
├─────────────────────────────────────────────────────────────────────────────────┤
│                                                                                  │
│   LEVEL 4/5: ENTERPRISE ZONE          VPC: enterprise-vpc (10.0.0.0/24)        │
│   ┌────────────────────────────────────────────────────────────────────────┐   │
│   │  Jump Host (Bastion) ──────────────────────────────────────────────────│   │
│   └────────────────────────────────────────────────────────────────────────┘   │
│                              │                                                   │
│                        VPC Peering                                              │
│                              ▼                                                   │
│   LEVEL 3: OPERATIONS ZONE (DMZ)      VPC: operations-vpc (10.1.0.0/24)        │
│   ┌────────────────────────────────────────────────────────────────────────┐   │
│   │  Historian Server    │    Security Monitor (Suricata IDS)              │   │
│   └────────────────────────────────────────────────────────────────────────┘   │
│                              │                                                   │
│                        VPC Peering                                              │
│                              ▼                                                   │
│   LEVEL 1/2: CONTROL ZONE             VPC: control-vpc (10.2.0.0/24)           │
│   ┌────────────────────────────────────────────────────────────────────────┐   │
│   │  PLC Simulator (Modbus TCP)    │    HMI Simulator                      │   │
│   └────────────────────────────────────────────────────────────────────────┘   │
│                                                                                  │
│   🔒 KEY SECURITY CONTROL: NO direct path from Enterprise to Control Zone      │
└─────────────────────────────────────────────────────────────────────────────────┘
```

## 🛡️ Security Controls

| Control | Implementation | Purpose |
|---------|---------------|---------|
| Network Segmentation | 3 VPCs with controlled peering | Zone isolation |
| Air-Gap Simulation | No Enterprise↔Control peering | Protect critical assets |
| Protocol Allowlisting | Firewall rules for Modbus (502), OPC-UA (4840) | Minimize attack surface |
| Intrusion Detection | Suricata with custom OT rules | Detect malicious activity |
| Egress Filtering | Control zone denied internet | Prevent data exfiltration |
| Centralized Logging | VPC Flow Logs + Suricata | Full visibility |

## 🔍 Detection Capabilities

The Suricata IDS detects:

- 🚨 **Unauthorized Modbus Write Commands** - Function Code 6 attacks
- 🚨 **New OT Connections** - Unexpected connections to port 502
- 🚨 **Zone Violations** - Traffic from unauthorized sources

Sample Alert:
```
[**] [1:1000002:1] OT ALERT: Unauthorized Modbus Write Command (FC 06) [**]
{TCP} 10.1.0.10:45076 -> 10.2.0.10:502
```

## 🚀 Quick Start

### Prerequisites

- GCP account with billing enabled
- Terraform >= 1.0.0
- gcloud CLI

### Deploy
```bash
# Clone the repository
git clone https://github.com/YOUR_USERNAME/ics-security-lab.git
cd ics-security-lab/terraform/environments/dev

# Configure variables
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your project ID

# Deploy
terraform init
terraform plan
terraform apply
```

### Connect
```bash
# SSH to Jump Host
gcloud compute ssh jump-host --zone=us-central1-a

# From Jump Host, access Operations zone
ssh 10.1.0.10
```

## 📁 Project Structure
```
ics-security-lab/
├── README.md
├── docs/
│   ├── architecture.md          # Network architecture details
│   ├── security-controls.md     # Security implementation
│   ├── attack-scenarios.md      # Red team testing
│   └── deployment-guide.md      # Setup instructions
├── terraform/
│   ├── modules/
│   │   ├── network/            # VPCs, subnets, peering
│   │   ├── compute/            # VM instances
│   │   └── firewall/           # Security rules
│   └── environments/
│       └── dev/                # Development config
├── detection/
│   └── suricata-rules/
│       └── ot-rules.rules      # Custom OT detection rules
└── scripts/
    ├── plc_simulator.py        # Modbus TCP server
    ├── modbus_client.py        # Historian client
    └── modbus_attack.py        # Attack simulation
```

## 📊 Attack Scenarios Tested

| Scenario | Vector | Result |
|----------|--------|--------|
| Reconnaissance | Port scan from Enterprise | ❌ Blocked (no route) |
| Direct Access | SSH Enterprise → Control | ❌ Blocked (firewall) |
| Pivot Attack | Historian → PLC | ✅ Detected (Suricata) |
| Malicious Write | Modbus FC6 command | ✅ Detected (Suricata) |
| Data Exfiltration | Control → Internet | ❌ Blocked (egress rules) |

## 💰 Cost Estimate

| Usage | Monthly Cost |
|-------|-------------:|
| Running 24/7 | ~$27 |
| 4 hours/day | ~$7 |

💡 **Tip:** Stop VMs when not in use:
```bash
gcloud compute instances stop jump-host historian-server security-monitor plc-simulator hmi-simulator --zone=us-central1-a
```

## 📚 References

- [Purdue Enterprise Reference Architecture](https://en.wikipedia.org/wiki/Purdue_Enterprise_Reference_Architecture)
- [IEC 62443 Industrial Security Standards](https://www.iec.ch/industrial-cybersecurity)
- [NIST SP 800-82 Guide to ICS Security](https://csrc.nist.gov/publications/detail/sp/800-82/rev-2/final)
- [Suricata Documentation](https://suricata.readthedocs.io/)

## 📄 License

MIT License - See [LICENSE](LICENSE) for details.

---

**Built for learning OT/ICS security** | Demonstrates defense-in-depth for industrial environments