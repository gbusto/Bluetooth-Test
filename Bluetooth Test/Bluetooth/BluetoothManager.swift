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
    var adData: [String : Any]
    var peripheral: CBPeripheral
    
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
    
    func getServiceUUIDs() -> NSArray {
        if adData[CoreBluetooth.CBAdvertisementDataServiceUUIDsKey] != nil {
            return adData[CoreBluetooth.CBAdvertisementDataServiceUUIDsKey] as! NSArray
        }
        
        return NSArray()
    }
}

class BluetoothManager: NSObject, ObservableObject {
    private var centralManager: CBCentralManager!
    
    @Published public var devices: [UUID: Device] = [:]
    
    @Published public var status: String = ""
        
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
            centralManager.scanForPeripherals(withServices: [])//withServices: [CBUUID(string: "0BC55B43-2935-4974-94DF-BA47FE7F44CD")])
            print("Started scanning")
            status = "Started scanning"
        }
        else {
            print("Central manager is already scanning...")
        }
    }
    
    func stopScanning() {
        if isPoweredOn() && centralManager.isScanning {
            centralManager.stopScan()
            print("Stopped scanning")
            status = "Stopped scanning"
        }
        else {
            print("Central manager already stopped scanning...")
        }
    }
    
    private func translateState(_ btState: CBManagerState) -> String {
        switch btState {
        case .unknown:
            return "BT central manager state is UNKNOWN"
        case .resetting:
            return "BT central manager state is RESETTING"
        case .unsupported:
            return "BT central manager state is UNSUPPORTED"
        case .unauthorized:
            return "BT central manager state is UNAUTHORIZED"
        case .poweredOff:
            return "BT central manager state is POWERED OFF"
        case .poweredOn:
            return "BT central manager state is POWERED ON"
        default:
            return "Got unknown BT central manager state int: \(btState.rawValue)"
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
        status = "Attempting to connect to \(devices[uuid]!.name)"
        
        let peripheral = devices[uuid]!.peripheral
        centralManager.connect(devices[uuid]!.peripheral, options: [
            CoreBluetooth.CBConnectPeripheralOptionNotifyOnConnectionKey: false,
            CoreBluetooth.CBConnectPeripheralOptionNotifyOnDisconnectionKey: false,
            CoreBluetooth.CBConnectPeripheralOptionNotifyOnNotificationKey: false,
            CoreBluetooth.CBConnectPeripheralOptionEnableTransportBridgingKey: false,
            CoreBluetooth.CBConnectPeripheralOptionRequiresANCS: false,
            CoreBluetooth.CBConnectPeripheralOptionStartDelayKey: NSNumber(value: 3)
        ])
        //peripheral.discoverServices([CBUUID(string: "0BC55B43-2935-4974-94DF-BA47FE7F44CD")])
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
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        print("Discovered services for peripheral \(peripheral.name)")
    }
}

extension BluetoothManager: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        print("New BT manager state is \(translateState(central.state))")
        status = "New BT manager state is \(translateState(central.state))"
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        //peripheral.delegate = self
        if let name = peripheral.name {
            devices[peripheral.identifier] = Device(name: name,
                                                    uuid: peripheral.identifier,
                                                    rssi: RSSI,
                                                    adData: advertisementData,
                                                    peripheral: peripheral)
            //print("Discovered peripheral: \(name) - \(peripheral.identifier) - \(translateRssi(RSSI))")
            print("------------------------------------")
            print("Advertisement data for \(name):")
            print(advertisementData)
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        if let name = peripheral.name {
            print("Successfully connected to peripheral \(name)")
            status = "Successfully connected to peripheral \(name)"
            
            //peripheral.readRSSI()
        }
        else {
            print("Successfully connected to peripheral \(peripheral.identifier)")
            status = "Successfully connected to peripheral \(peripheral.identifier)"
        }
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        if let name = peripheral.name {
            print("Failed to connect to peripheral \(name)")
            status = "Failed to connect to peripheral \(name)"
        }
        else {
            print("Failed to connect to peripheral \(peripheral.identifier)")
            status = "Failed to connect to peripheral \(peripheral.identifier)"
        }
        
        if let err = error {
            print(err)
            status = err.localizedDescription
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        if let name = peripheral.name {
            print("Disconnected from peripheral \(name)")
            status = "Disconnected from peripheral \(name)"
        }
        else {
            print("Disconnected from peripheral \(peripheral.identifier)")
            status = "Disconnected from peripheral \(peripheral.identifier)"
        }
        
        if let err = error {
            print(err)
            status = err.localizedDescription
        }
    }
}

