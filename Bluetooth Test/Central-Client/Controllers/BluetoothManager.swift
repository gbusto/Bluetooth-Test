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
    
    @Published public var isScanning: Bool = false
    
    @Published public var state: String = ""
    
    @Published public var error: String = ""
    
    @Published public var peripheralOutput: String = ""
    
    @Published public var peripheralError: String = ""
    
    @Published public var lastMessage: String = ""
    
    private var characteristic: CBCharacteristic?
    
        
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
            centralManager.scanForPeripherals(withServices: [CBUUID(nsuuid: PeripheralManager.CHAT_SERVICE_UUID)])
            print("Started scanning")
            self.isScanning = true
        }
        else {
            print("Central manager is already scanning...")
        }
    }
    
    func stopScanning() {
        if isPoweredOn() && centralManager.isScanning {
            centralManager.stopScan()
            print("Stopped scanning")
            self.isScanning = false
        }
        else {
            print("Central manager already stopped scanning...")
        }
    }
    
    private func translateState(_ btState: CBManagerState) -> String {
        switch btState {
        case .unknown:
            return "unknown"
        case .resetting:
            return "resetting"
        case .unsupported:
            return "unsupported"
        case .unauthorized:
            return "unauthorized"
        case .poweredOff:
            return "powered off"
        case .poweredOn:
            return "powered on"
        default:
            return "enexpected \(btState.rawValue)"
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
        self.state = "Attempting to connect to \(devices[uuid]!.name)"
        
        centralManager.connect(devices[uuid]!.peripheral, options: [
            CoreBluetooth.CBConnectPeripheralOptionNotifyOnConnectionKey: false,
            CoreBluetooth.CBConnectPeripheralOptionNotifyOnDisconnectionKey: false,
            CoreBluetooth.CBConnectPeripheralOptionNotifyOnNotificationKey: false,
            CoreBluetooth.CBConnectPeripheralOptionEnableTransportBridgingKey: false,
            CoreBluetooth.CBConnectPeripheralOptionRequiresANCS: false,
            CoreBluetooth.CBConnectPeripheralOptionStartDelayKey: NSNumber(value: 3)
        ])
    }
    
    func disconnectFromPeripheral(_ uuid: UUID) {
        let peripheral = devices[uuid]!.peripheral
        centralManager.cancelPeripheralConnection(peripheral)
    }
    
    func readPeripheralRSSI(uuid: UUID) {
        let peripheral = devices[uuid]!.peripheral
        peripheral.readRSSI()
    }
    
    func readMessage(uuid: UUID) {
        let peripheral = devices[uuid]!.peripheral
        if let ch = self.characteristic {
            peripheral.readValue(for: ch)
        }
        else {
            print("No characteristic found to read the message")
            self.error = "No characteristic found to read the message"
        }
    }
}

extension BluetoothManager: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didReadRSSI RSSI: NSNumber, error: Error?) {
        if let name = peripheral.name {
            print("Read RSSI for peripheral \(name) - \(RSSI)")
            self.peripheralOutput = "Read RSSI for peripheral \(name) - \(RSSI)"
        }
        
        if let err = error {
            print(err)
            self.peripheralError = err.localizedDescription
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let name = peripheral.name {
            print("Discovered services for peripheral \(name)")
            self.peripheralOutput = "Discovered services for peripheral \(name)"
        }
        
        // A nasty set of nested loops and conditionals to get Characteristic for where the "message" will live
        // so we can read it easily later on
        if let services = peripheral.services {
            for service in services {
                if service.uuid == CBUUID(nsuuid: PeripheralManager.CHAT_SERVICE_UUID) {
                    peripheral.discoverCharacteristics([CBUUID(nsuuid: PeripheralManager.CHAT_SERVICE_MESSAGE_UUID)], for: service)
                }
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let name = peripheral.name {
            print("Discovered characteristics for peripheral \(name)")
            self.peripheralOutput = "Discovered characteristics for peripheral \(name)"
        }
        
        if let characteristics = service.characteristics {
            for ch in characteristics {
                if ch.uuid == CBUUID(nsuuid: PeripheralManager.CHAT_SERVICE_MESSAGE_UUID) {
                    self.characteristic = ch
                    self.peripheralOutput = "Discovered services and found 'message' characteristic"
                }
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if let ch = self.characteristic {
            if ch.uuid == characteristic.uuid {
                if let data = characteristic.value {
                    self.lastMessage = String(decoding: data, as: UTF8.self)
                }
            }
        }
    }
}

extension BluetoothManager: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        print("New BT manager state is \(translateState(central.state))")
        self.state = translateState(central.state)
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
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
        // Stop scanning if we successfully connected to a device
        self.stopScanning()
        
        // Important line of code! If we don't call this, we can't then call things like .readRSSI().
        // The peripheral's delegate MUST be set.
        peripheral.delegate = self
        
        if let name = peripheral.name {
            print("Successfully connected to peripheral \(name)")
            self.peripheralOutput = "Successfully connected to peripheral \(name)"
        }
        
        peripheral.discoverServices([CBUUID(nsuuid: PeripheralManager.CHAT_SERVICE_UUID)])
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        if let name = peripheral.name {
            print("Failed to connect to peripheral \(name)")
            self.peripheralOutput = "Failed to connect to peripheral \(name)"
        }
        
        if let err = error {
            print(err)
            self.peripheralError = err.localizedDescription
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        if let name = peripheral.name {
            print("Disconnected from peripheral \(name)")
            self.state = "Disconnected from peripheral \(name)"
        }
        
        if let err = error {
            print(err)
            self.error = err.localizedDescription
        }
    }
}

