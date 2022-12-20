//
//  BluetoothManager.swift
//  Bluetooth Test
//
//  Created by Gabriel Busto on 12/19/22.
//

import Foundation
import CoreBluetooth

struct Device {
    var name: String
    var uuid: UUID
    var rssi: NSNumber
    var peripheral: CBPeripheral
}

class BluetoothManager: NSObject, ObservableObject {
    private var centralManager: CBCentralManager!
    
    @Published public var devices: [UUID: Device] = [:]
        
    func start() {
        if centralManager == nil {
            centralManager = .init(CBCentralManager(delegate: self, queue: .main))
        }
    }
    
    func isPoweredOn() -> Bool {
        return centralManager.state.rawValue == 5
    }
    
    func startScanning() {
        if isPoweredOn() && !centralManager.isScanning {
            centralManager.scanForPeripherals(withServices: [])
            print("Started scanning")
        }
        else {
            print("Central manager is already scanning...")
        }
    }
    
    func stopScanning() {
        if isPoweredOn() && centralManager.isScanning {
            centralManager.stopScan()
            print("Stopped scanning")
        }
        else {
            print("Central manager already stopped scanning...")
        }
    }
    
    private func translateState(_ btState: CBManagerState.RawValue) {
        switch btState {
        case 0:
            print("BT central manager state is UNKNOWN")
            break
        case 1:
            print("BT central manager state is RESETTING")
            break
        case 2:
            print("BT central manager state is UNSUPPORTED")
            break
        case 3:
            print("BT central manager state is UNAUTHORIZED")
            break
        case 4:
            print("BT central manager state is POWERED OFF")
            break
        case 5:
            print("BT central manager state is POWERED ON")
            break
        default:
            print("Got unknown BT central manager state int: \(btState)")
            break
        }
    }
    
    func translateRssi(_ RSSI: NSNumber) -> String {
        // 🔴🟠🟡🟢❌
        if RSSI.self is Int {
            let rssi = RSSI as! Int
            if rssi > -55 {
                return "🟢"
            }
            else if rssi > -67 && rssi <= -55 {
                return "🟡"
            }
            else if rssi > -80 && rssi <= -67 {
                return "🟠"
            }
            else if rssi > -90 && rssi <= -80 {
                return "🔴"
            }
            else {
                return "❌"
            }
        }
        else {
            return "RSSI value is an unexpected value type"
        }
    }
    
    func connectToPeripheral(_ uuid: UUID) {
        print("Attempting to connect to \(devices[uuid]!.name)")
        centralManager.connect(devices[uuid]!.peripheral)
    }
    
}

extension BluetoothManager: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didReadRSSI RSSI: NSNumber, error: Error?) {
        if let name = peripheral.name {
            print("Read RSSI for peripheral \(name) - \(RSSI)")
        }
        else {
            print("Read RSSI for peripheral \(peripheral.identifier) - \(RSSI)")
        }
        
        if let err = error {
            print(err)
        }
    }
    
    func peripheralDidUpdateRSSI(_ peripheral: CBPeripheral, error: Error?) {
        if let name = peripheral.name {
            print("Read RSSI for peripheral \(name) - \(peripheral.rssi)")
        }
        else {
            print("Read RSSI for peripheral \(peripheral.identifier) - \(peripheral.rssi)")
        }
        
        if let err = error {
            print(err)
        }

    }
}

extension BluetoothManager: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        print("New BT manager state")
        translateState(central.state.rawValue)
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        peripheral.delegate = self
        if let name = peripheral.name {
            devices[peripheral.identifier] = Device(name: name,
                                                    uuid: peripheral.identifier,
                                                    rssi: RSSI,
                                                    peripheral: peripheral)
            //print("Discovered peripheral: \(name) - \(peripheral.identifier) - \(translateRssi(RSSI))")
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        if let name = peripheral.name {
            print("Successfully connected to peripheral \(name)")
            peripheral.readRSSI()
        }
        else {
            print("Successfully connected to peripheral \(peripheral.identifier)")
        }
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        if let name = peripheral.name {
            print("Failed to connect to peripheral \(name)")
        }
        else {
            print("Failed to connect to peripheral \(peripheral.identifier)")
        }
        
        if let err = error {
            print(err)
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        if let name = peripheral.name {
            print("Disconnected from peripheral \(name)")
        }
        else {
            print("Disconnected from peripheral \(peripheral.identifier)")
        }
        
        if let err = error {
            print(err)
        }
    }
}

