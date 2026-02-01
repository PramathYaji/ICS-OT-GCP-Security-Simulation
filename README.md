# 🏭 ICS/OT Security Lab

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
┌────────────────────────────────────────────────────────────────────────────────┐
│                              PURDUE MODEL IMPLEMENTATION                       │
├────────────────────────────────────────────────────────────────────────────────┤
│                                                                                │
│   LEVEL 4/5: ENTERPRISE ZONE          VPC: enterprise-vpc (10.0.0.0/24)        │
│   ┌────────────────────────────────────────────────────────────────────────┐   │
│   │  Jump Host (Bastion) ──────────────────────────────────────────────────│   │
│   └────────────────────────────────────────────────────────────────────────┘   │
│        (IP= 10.0.0.2)                                                          │                                                 
│                        VPC Peering                                             │
│                              ▼                                                 │
│   LEVEL 3: OPERATIONS ZONE (DMZ)      VPC: operations-vpc (10.1.0.0/24)        │
│   ┌────────────────────────────────────────────────────────────────────────┐   │
│   │  Historian Server    │    Security Monitor (Suricata IDS)              │   │
│   └────────────────────────────────────────────────────────────────────────┘   │
│        (IP= 10.1.0.10)                  (IP= 10.1.0.20)                        │                                                 
│                        VPC Peering                                             │
│                              ▼                                                 │
│   LEVEL 1/2: CONTROL ZONE             VPC: control-vpc (10.2.0.0/24)           │
│   ┌────────────────────────────────────────────────────────────────────────┐   │
│   │  PLC Simulator (Modbus TCP)    │    HMI Simulator                      │   │
│   └────────────────────────────────────────────────────────────────────────┘   │
│               (IP= 10.2.0.10)             (IP= 10.2.0.20)                      │
│      KEY SECURITY CONTROL: NO direct path from Enterprise to Control Zone      │
└────────────────────────────────────────────────────────────────────────────────┘
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

## 🔐 Network Segmentation & Security Policies

To simulate a realistic industrial environment, this lab implements strict **Network Segmentation** based on the **Purdue Enterprise Reference Architecture (PERA)**. The network is divided into three distinct Virtual Private Clouds (VPCs) with granular peering and firewall rules to enforce a **Zero Trust** model.

### 1. The Purdue Model Implementation

| Zone | Purdue Level | VPC CIDR | Security Context |
| :--- | :--- | :--- | :--- |
| **Enterprise Zone** | Level 4/5 | `10.0.0.0/24` | **Untrusted/Corporate.** Contains the Jump Host. Simulates the business network. |
| **Operations Zone** | Level 3 | `10.1.0.0/24` | **DMZ.** Contains the Historian and Security Monitor. Acts as the bridge between IT and OT. |
| **Control Zone** | Level 1/2 | `10.2.0.0/24` | **Critical/Air-Gapped.** Contains the PLC and HMI. Strictly isolated from the internet and Enterprise zone. |

### 2. Firewall & Traffic Control Policies

We implemented a "Deny-by-Default" strategy, allowing only necessary industrial protocols.

#### 🛡️ Policy A: The "Air-Gap" (Egress Filtering)
**Objective:** Prevent malware C2 (Command & Control) callbacks and data exfiltration from the critical zone.
* **Implementation:** The Control Zone (`10.2.0.0/24`) has a high-priority firewall rule denying **all** egress traffic to `0.0.0.0/0` (Internet).
* **Validation:** Attempts to `curl google.com` or ping external IPs from the PLC fail immediately.

#### 🛡️ Policy B: Prevention of Lateral Movement
**Objective:** Stop attackers in the Corporate network from directly accessing PLCs.
* **Implementation:**
    * **VPC Peering:** Enterprise is peered *only* with Operations. Operations is peered with Control.
    * **Route Policy:** There is **no route** advertised between Enterprise and Control.
    * **Firewall Rule:** `deny-enterprise-to-control` explicitly blocks ingress from `10.0.0.0/24` to `10.2.0.0/24`.
* **Validation:** `nmap` scans from the Jump Host against the PLC return all ports as `filtered`.

#### 🛡️ Policy C: Secure Administration (Bastion Access)
**Objective:** Allow secure management without exposing ports to the public internet.
* **Implementation:**
    * SSH (Port 22) is blocked from the public internet.
    * Access is only allowed via **Google Cloud Identity-Aware Proxy (IAP)** (`35.235.240.0/20`).
    * Management traffic must "hop" through the Jump Host to the Historian, and then to the PLC (Pivot architecture).

### 3. Traffic Mirroring Policy
To enable out-of-band monitoring without disrupting industrial processes, we implemented a **Packet Mirroring Policy**:
* **Source:** All ingress/egress traffic in the Operations Subnet (`10.1.0.0/24`).
* **Destination:** An Internal Load Balancer (ILB) front-ending the Suricata IDS.
* **Result:** The Security Monitor sees real-time traffic (including attacks) without being inline, removing it as a potential point of failure for plant operations.

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

## 🛠️ Tools & Technologies

### Cloud & Infrastructure
* **Google Cloud Platform (GCP):** Compute Engine, VPC, Cloud NAT, Cloud Logging, Packet Mirroring.
* **Terraform:** For declarative Infrastructure as Code (IaC) provisioning.

### Security & Detection
* **Suricata IDS:** Open-source intrusion detection engine configured with custom rules.
* **Google Cloud Operations Suite:** Stackdriver/Cloud Logging for centralized log aggregation.
* **Tcpdump:** For packet capture and verification of mirrored traffic.
* **Nmap:** Used for network reconnaissance and verifying firewall segmentation.

### Simulation & OT Protocols
* **Python 3:** Core language for all simulation scripts.
* **Pymodbus:** Library used to create the PLC server, HMI client, and attack scripts.
* **Modbus TCP:** The primary industrial protocol simulated and analyzed.
* **Debian Linux:** Operating system for all virtual machines.

## 📊 Attack Scenarios Tested

| Scenario | Vector | Result |
|----------|--------|--------|
| Reconnaissance | Port scan from Enterprise | ❌ Blocked (no route) |
| Direct Access | SSH Enterprise → Control | ❌ Blocked (firewall) |
| Pivot Attack | Historian → PLC | ✅ Detected (Suricata) |
| Malicious Write | Modbus FC6 command | ✅ Detected (Suricata) |
| Data Exfiltration | Control → Internet | ❌ Blocked (egress rules) |

💡 **Tip:** Stop VMs when not in use:
```bash
gcloud compute instances stop jump-host historian-server security-monitor plc-simulator hmi-simulator --zone=us-central1-a
```

## 📚 References

- [Purdue Enterprise Reference Architecture](https://en.wikipedia.org/wiki/Purdue_Enterprise_Reference_Architecture)
- [IEC 62443 Industrial Security Standards](https://www.iec.ch/industrial-cybersecurity)
- [NIST SP 800-82 Guide to ICS Security](https://csrc.nist.gov/publications/detail/sp/800-82/rev-2/final)
- [Suricata Documentation](https://suricata.readthedocs.io/)


**Built for learning OT/ICS security** | Demonstrates defense-in-depth for industrial environments





