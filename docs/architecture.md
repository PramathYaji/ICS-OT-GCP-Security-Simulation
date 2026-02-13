# ICS Security Lab - Architecture Documentation

## Overview

This project implements a **Purdue Model-based network architecture** on Google Cloud Platform to demonstrate OT/ICS security best practices.

## Network Architecture
```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                        Purdue Model-based Architecture                          │
├─────────────────────────────────────────────────────────────────────────────────┤
│                                                                                 │
│   LEVEL 4/5: ENTERPRISE ZONE                                                    │
│   ┌────────────────────────────────────────────────────────────────────────┐    │
│   │  VPC: enterprise-vpc (10.0.0.0/24)                                     │    │
│   │  └── Jump Host (10.0.0.10) - Bastion/Entry point                       │    │
│   └────────────────────────────────────────────────────────────────────────┘    │
│                              │                                                  │
│                        VPC Peering                                              │
│                              │                                                  │
│   LEVEL 3: OPERATIONS ZONE (DMZ)                                                │
│   ┌────────────────────────────────────────────────────────────────────────┐    │
│   │  VPC: operations-vpc (10.1.0.0/24)                                     │    │
│   │  ├── Historian Server (10.1.0.10) - Data collection                    │    │
│   │  └── Security Monitor (10.1.0.20) - Suricata IDS                       │    │
│   └────────────────────────────────────────────────────────────────────────┘    │
│                              │                                                  │
│                        VPC Peering                                              │
│                              │                                                  │
│   LEVEL 1/2: CONTROL ZONE                                                       │
│   ┌────────────────────────────────────────────────────────────────────────┐    │
│   │  VPC: control-vpc (10.2.0.0/24)                                        │    │
│   │  ├── PLC Simulator (10.2.0.10) - Modbus TCP Server                     │    │
│   │  └── HMI Simulator (10.2.0.20) - Operator Interface                    │    │
│   └────────────────────────────────────────────────────────────────────────┘    │
│                                                                                 │
│       NO DIRECT PATH: Enterprise → Control (Air-gap enforced)                   │
│                                                                                 │
└─────────────────────────────────────────────────────────────────────────────────┘
```

## Purdue Model Implementation

| Purdue Level | Zone Name | VPC | Purpose |
|--------------|-----------|-----|---------|
| Level 4/5 | Enterprise | enterprise-vpc | Corporate IT, business systems |
| Level 3 | Operations (DMZ) | operations-vpc | Historian, security monitoring |
| Level 1/2 | Control | control-vpc | PLCs, HMIs, control systems |

## VPC Peering Configuration

| Peering | Direction | Purpose |
|---------|-----------|---------|
| enterprise-to-operations | Enterprise ↔ Operations | Allow IT access to DMZ |
| operations-to-control | Operations ↔ Control | Allow data collection from OT |
| **NO** enterprise-to-control | Blocked | Enforce air-gap |

## IP Address Allocation

### Enterprise Zone (10.0.0.0/24)
| Host | IP Address | Role |
|------|------------|------|
| Jump Host | 10.0.0.10 | SSH bastion, entry point |

### Operations Zone (10.1.0.0/24)
| Host | IP Address | Role |
|------|------------|------|
| Historian | 10.1.0.10 | Data collection, Modbus client |
| Security Monitor | 10.1.0.20 | Suricata IDS, log aggregation |

### Control Zone (10.2.0.0/24)
| Host | IP Address | Role |
|------|------------|------|
| PLC Simulator | 10.2.0.10 | Modbus TCP server (port 502) |

| HMI Simulator | 10.2.0.20 | Operator interface |

