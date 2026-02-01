#!/usr/bin/env python3
"""
PLC Simulator - Modbus TCP Server
Simulates a simple industrial PLC for the ICS Security Lab
"""

from pymodbus.server import StartTcpServer
from pymodbus.datastore import ModbusSequentialDataBlock, ModbusServerContext, ModbusDeviceContext
import logging
import threading
import time
import random

logging.basicConfig(level=logging.INFO)
log = logging.getLogger(__name__)

def update_sensor_values(context):
    """Simulate real sensor data changing over time"""
    while True:
        temp = random.randint(68, 72)
        context[0].setValues(3, 0, [temp])
        
        pressure = random.randint(95, 105)
        context[0].setValues(3, 1, [pressure])
        
        flow = random.randint(45, 55)
        context[0].setValues(3, 2, [flow])
        
        level = random.randint(75, 85)
        context[0].setValues(3, 3, [level])
        
        log.info(f"Sensor Update - Temp: {temp}F, Pressure: {pressure} PSI, Flow: {flow} GPM, Level: {level}%")
        time.sleep(5)

def run_plc_server():
    """Start the Modbus TCP Server"""
    coils = ModbusSequentialDataBlock(0, [0]*100)
    discrete_inputs = ModbusSequentialDataBlock(0, [0]*100)
    holding_registers = ModbusSequentialDataBlock(0, [70, 100, 50, 80] + [0]*96)
    input_registers = ModbusSequentialDataBlock(0, [0]*100)
    
    store = ModbusDeviceContext(
        di=discrete_inputs,
        co=coils,
        hr=holding_registers,
        ir=input_registers
    )
    
    context = ModbusServerContext(devices=store, single=True)
    
    sensor_thread = threading.Thread(target=update_sensor_values, args=(context,))
    sensor_thread.daemon = True
    sensor_thread.start()
    
    log.info("="*60)
    log.info("PLC SIMULATOR - Modbus TCP Server")
    log.info("="*60)
    log.info("Listening on 0.0.0.0:502")
    log.info("="*60)
    
    StartTcpServer(context=context, address=("0.0.0.0", 502))

if __name__ == "__main__":
    run_plc_server()