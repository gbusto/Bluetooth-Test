//
//  CentralView.swift
//  Bluetooth Test
//
//  Created by Gabriel Busto on 12/20/22.
//

import Foundation
import SwiftUI

struct CentralManagerView: View {
    @ObservedObject var bluetoothManager: BluetoothManager = BluetoothManager()

    var body: some View {
        NavigationView {
            VStack {
                Text("You are now the Central/Client")
                    .font(.title)
                    .foregroundColor(.green)
                
                CentralScanningView(isScanning: $bluetoothManager.isScanning)
                
                Spacer()
                
                CentralStateView(state: $bluetoothManager.state)
                
                CentralErrorView(error: $bluetoothManager.error)
                
                CentralCommandView(bluetoothManager: bluetoothManager)
                
                Spacer()
                
                DevicesList(btManager: bluetoothManager,
                            _devices: $bluetoothManager.devices)
            }
            .onAppear {
                bluetoothManager.start()
            }
        }
    }
}

struct CentralScanningView: View {
    @Binding var isScanning: Bool
    
    var body: some View {
        Text(isScanning ? "Scanning" : "Not scanning")
            .font(.body)
            .foregroundColor(.red)
            .multilineTextAlignment(.center)
    }
}

struct CentralStateView: View {
    @Binding var state: String
    
    var body: some View {
        Text("Central state: \(state)")
            .font(.body)
            .foregroundColor(.red)
            .multilineTextAlignment(.center)
    }
}

struct CentralErrorView: View {
    @Binding var error: String
    
    var body: some View {
        Text("Error: \(error)")
            .font(.body)
            .foregroundColor(.red)
            .multilineTextAlignment(.center)
    }
}

struct CentralCommandView: View {
    var bluetoothManager: BluetoothManager
    
    var body: some View {
        Button("Start Scanning", action: startBTScanning)
            .buttonStyle(.bordered)
            .foregroundColor(.blue)
        Button("Stop Scanning", action: stopBTScanning)
            .buttonStyle(.bordered)
            .foregroundColor(.blue)
    }
    
    func startBTScanning() {
        bluetoothManager.startScanning()
    }
    
    func stopBTScanning() {
        bluetoothManager.stopScanning()
    }
}

struct DevicesList: View {
    var btManager: BluetoothManager
    @Binding var _devices: [UUID: Device]
    
    var body: some View {
        ScrollView {
            ForEach(Array(_devices.keys), id: \.self) { key in
                DeviceView(btManager: btManager,
                           device: _devices[key]!,
                           textColor: .red)
            }
        }
        .padding()
    }
}

struct DeviceView: View {
    var btManager: BluetoothManager
    var device: Device
    var textColor: Color
    var maxStringLength: Int = 20
    
    var body: some View {
        NavigationLink("Name: \(truncatedName(name: device.name))",
                       destination: PeripheralView(bluetoothManager: btManager,
                                                   uuid: device.uuid,
                                                   peripheralName: device.name))
            .foregroundColor(.red)
    }
    
    func truncatedName(name: String) -> String {
        if name.count > maxStringLength {
            let start = name.startIndex
            let end = name.index(start, offsetBy: maxStringLength - 3)
            let _name = name[start..<end]
            return String(_name + "...")
        }
        
        return name
    }
}

struct CentralManagerView_Previews: PreviewProvider {
    static var previews: some View {
        CentralManagerView()
    }
}
