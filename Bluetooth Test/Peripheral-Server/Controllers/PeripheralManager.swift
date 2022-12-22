//
//  PeripheralManager.swift
//  Bluetooth Test
//
//  Created by Gabriel Busto on 12/20/22.
//

import Foundation
import CoreBluetooth

class PeripheralManager: NSObject, ObservableObject {
    private var peripheralManager: CBPeripheralManager!
    
    private var createdServices: Bool = false
    
    private var services: [CBMutableService] = []
    
    static public var CHAT_SERVICE_UUID: UUID = UUID(uuidString: "63069053-2513-4f84-86de-a5b28841dc54")!
    static public var CHAT_SERVICE_MESSAGE_UUID: UUID = UUID(uuidString: "4c846b78-3769-4f4b-b665-53e273fb2214")!
    
    @Published public var state: String = ""
    
    @Published public var isAdvertising: Bool = false
    
    @Published public var error: String = ""
        
    func start() {
        if peripheralManager == nil {
            peripheralManager = .init(CBPeripheralManager(delegate: self, queue: .main))
        }
    }
    
    func isPoweredOn() -> Bool {
        return peripheralManager.state.rawValue == 5
    }
    
    func updateServices(_ text: String = "test") {
        removeServices()
        addServices(text)
    }
    
    func removeServices() {
        peripheralManager.removeAllServices()
        createdServices = false
    }
        
    func addServices(_ text: String) {
        if createdServices {
            return
        }
        
        let serviceUuid1 = PeripheralManager.CHAT_SERVICE_UUID
        let characteristicUuid1 = PeripheralManager.CHAT_SERVICE_MESSAGE_UUID
        print("Service UUID is \(serviceUuid1)")
        print("Characteristic UUID is \(characteristicUuid1)")
        let service1: CBMutableService = CBMutableService(type: CBUUID(nsuuid: serviceUuid1), primary: true)
        let characteristic1: CBMutableCharacteristic = CBMutableCharacteristic(type: CBUUID(nsuuid: characteristicUuid1),
                                                                               properties: [CBCharacteristicProperties.read],
                                                                               value: text.data(using: .utf8),
                                                                               permissions: CBAttributePermissions.readable)

        service1.characteristics = [characteristic1]
        
        peripheralManager.add(service1)
        
        services.append(service1)
        
        createdServices = true
    }
    
    func startAdvertising() {
        if isPoweredOn() && !peripheralManager.isAdvertising {
            peripheralManager.startAdvertising([
                CoreBluetooth.CBAdvertisementDataLocalNameKey: NSString(string: "BTDEV"),
                CoreBluetooth.CBAdvertisementDataServiceUUIDsKey: services.map { $0.uuid }
            ])
            self.isAdvertising = true
            print("Advertising!")
        }
        else {
            print("Already started advertising")
        }
    }
    
    func stopAdvertising() {
        if isPoweredOn() && peripheralManager.isAdvertising {
            peripheralManager.stopAdvertising()
            self.isAdvertising = false
            print("Stopped advertising")
        }
        else {
            print("Already stopped advertising")
        }
    }
    
    private func translateState(_ pState: CBManagerState) -> String {
        switch pState {
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
            return "unexpected \(pState.rawValue)"
        }
    }
}

extension PeripheralManager: CBPeripheralManagerDelegate {
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        print("[Peripheral Manager] New BT manager state")
        self.state = translateState(peripheral.state)
    }
    
    func peripheralManagerIsReady(toUpdateSubscribers peripheral: CBPeripheralManager) {
        print("[Peripheral Manager] Peripheral manager is ready to update subscribers")
    }
    
    func peripheralManagerDidStartAdvertising(_ peripheral: CBPeripheralManager, error: Error?) {
        print("[Peripheral Manager] Started advertising")
        
        if let err = error {
            self.error = err.localizedDescription
        }
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, central: CBCentral, didSubscribeTo characteristic: CBCharacteristic) {
        print("[Peripheral Manager] Subscribed to \(characteristic.uuid)")
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, central: CBCentral, didUnsubscribeFrom characteristic: CBCharacteristic) {
        print("[Peripheral Manager] Unsibscribed from \(characteristic.uuid)")
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveRead request: CBATTRequest) {
        print("[Peripheral Manager] Received READ request")
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveWrite requests: [CBATTRequest]) {
        print("[Peripheral Manager] Received WRITE request")
    }
}
