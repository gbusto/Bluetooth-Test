//
//  PeripheralManager.swift
//  Bluetooth Test
//
//  Created by Gabriel Busto on 12/20/22.
//

import Foundation
import CoreBluetooth

class PeripheralManager: NSObject {
    private var peripheralManager: CBPeripheralManager!
    
    private var createdServices: Bool = false
    
    private var services: [CBMutableService] = []
    
    func start() {
        if peripheralManager == nil {
            peripheralManager = .init(CBPeripheralManager(delegate: self, queue: .main))
        }
    }
    
    func isPoweredOn() -> Bool {
        return peripheralManager.state.rawValue == 5
    }
    
    func addServices() {
        if createdServices {
            return
        }
        
        let serviceUuid1 = UUID()
        let characteristicUuid1 = UUID()
        print("Service UUID is \(serviceUuid1)")
        print("Characteristic UUID is \(characteristicUuid1)")
        let service1: CBMutableService = CBMutableService(type: CBUUID(nsuuid: serviceUuid1), primary: true)
        let characteristic1: CBMutableCharacteristic = CBMutableCharacteristic(type: CBUUID(nsuuid: characteristicUuid1),
                                                                               properties: [CBCharacteristicProperties.read],
                                                                               value: "test".data(using: .utf8),
                                                                               permissions: CBAttributePermissions.readable)
        let service2: CBMutableService = CBMutableService(type: CBUUID(nsuuid: UUID()), primary: false)
        let characteristic2: CBMutableCharacteristic = CBMutableCharacteristic(type: CBUUID(nsuuid: UUID()),
                                                                               properties: [CBCharacteristicProperties.read],
                                                                               value: "abcd".data(using: .utf8),
                                                                               permissions: CBAttributePermissions.readable)

        service1.characteristics = [characteristic1]
        service2.characteristics = [characteristic2]
        
        peripheralManager.add(service1)
        peripheralManager.add(service2)
        
        services.append(service1)
        services.append(service2)
        
        createdServices = true
    }
    
    func startAdvertising() {
        if isPoweredOn() && !peripheralManager.isAdvertising {
            peripheralManager.startAdvertising([
                CoreBluetooth.CBAdvertisementDataLocalNameKey: NSString(string: "BTDEV"),
                CoreBluetooth.CBAdvertisementDataServiceUUIDsKey: services.map { $0.uuid }
            ])
            print("Advertising!")
        }
        else {
            print("Already started advertising")
        }
    }
    
    func stopAdvertising() {
        if isPoweredOn() && peripheralManager.isAdvertising {
            peripheralManager.stopAdvertising()
            print("Stopped advertising")
        }
        else {
            print("Already stopped advertising")
        }
    }
    
    private func translateState(_ pState: CBManagerState) {
        switch pState {
        case .unknown:
            print("BT central manager state is UNKNOWN")
            break
        case .resetting:
            print("BT central manager state is RESETTING")
            break
        case .unsupported:
            print("BT central manager state is UNSUPPORTED")
            break
        case .unauthorized:
            print("BT central manager state is UNAUTHORIZED")
            break
        case .poweredOff:
            print("BT central manager state is POWERED OFF")
            break
        case .poweredOn:
            print("BT central manager state is POWERED ON")
            break
        default:
            print("Got unknown BT central manager state int: \(pState.rawValue)")
            break
        }
    }
}

extension PeripheralManager: CBPeripheralManagerDelegate {
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        print("[Peripheral Manager] New BT manager state")
        translateState(peripheral.state)
        
        if (isPoweredOn()) {
            addServices()
        }
    }
    
    func peripheralManagerIsReady(toUpdateSubscribers peripheral: CBPeripheralManager) {
        print("[Peripheral Manager] Peripheral manager is ready to update subscribers")
    }
    
    func peripheralManagerDidStartAdvertising(_ peripheral: CBPeripheralManager, error: Error?) {
        print("[Peripheral Manager] Started advertising")
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
