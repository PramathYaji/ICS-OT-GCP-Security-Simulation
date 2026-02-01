#!/usr/bin/env python3
"""
Modbus Client - Reads data from PLC Simulator
"""

from pymodbus.client import ModbusTcpClient
import time
import logging

logging.basicConfig(level=logging.INFO)
log = logging.getLogger(__name__)

PLC_IP = "10.2.0.10"
PLC_PORT = 502

def read_plc_data():
    client = ModbusTcpClient(PLC_IP, port=PLC_PORT)
    
    if not client.connect():
        log.error(f"Failed to connect to PLC at {PLC_IP}:{PLC_PORT}")
        return
    
    log.info("="*60)
    log.info("HISTORIAN - Connected to PLC")
    log.info("="*60)
    
    try:
        while True:
            result = client.read_holding_registers(0, 4)
            
            if not result.isError():
                temp = result.registers[0]
                pressure = result.registers[1]
                flow = result.registers[2]
                level = result.registers[3]
                
                log.info(f"PLC Data - Temp: {temp}F | Pressure: {pressure} PSI | Flow: {flow} GPM | Level: {level}%")
            else:
                log.error(f"Error reading registers: {result}")
            
            time.sleep(3)
    
    except KeyboardInterrupt:
        log.info("Stopping client...")
    finally:
        client.close()

if __name__ == "__main__":
    read_plc_data()
EOF