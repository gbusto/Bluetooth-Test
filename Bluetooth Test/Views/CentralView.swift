//
//  CentralView.swift
//  Bluetooth Test
//
//  Created by Gabriel Busto on 12/20/22.
//

import Foundation
import SwiftUI

struct CentralView: View {
    @ObservedObject var bluetoothManager: BluetoothManager = BluetoothManager()

    var body: some View {
        VStack {
            Text("You are now the Central/Client")
                .font(.title)
                .foregroundColor(.green)

            Spacer()
            
            StatusView(status: $bluetoothManager.status)
                        
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

struct StatusView: View {
    @Binding var status: String
    
    var body: some View {
        Text(status)
            .font(.body)
            .foregroundColor(.red)
            .multilineTextAlignment(.center)
            .padding()
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
        HStack {
            Text("Name: \(truncatedName(name: device.name))")
                .foregroundColor(textColor)
            Text("S: \(device.getServiceUUIDs().count)")
            Text("\(device.translateRssi(_: device.rssi))")
        }
        .padding()
        .onTapGesture {
            btManager.connectToPeripheral(device.uuid)
        }
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

struct CentralView_Previews: PreviewProvider {
    static var previews: some View {
        CentralView()
    }
}
