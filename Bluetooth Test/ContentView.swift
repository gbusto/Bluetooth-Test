//
//  ContentView.swift
//  Bluetooth Test
//
//  Created by Gabriel Busto on 12/19/22.
//

import SwiftUI
import CoreData
import CoreBluetooth

struct ContentView: View {
    @ObservedObject var bluetoothManager: BluetoothManager = BluetoothManager()
    
    @State var isScanning: Bool = false
    
    var body: some View {
        NavigationView {
            VStack {
                VStack {
                    ScanStatus(isScanning: isScanning)
                    Button("Scan", action: startBTScanning)
                        .buttonStyle(.bordered)
                        .foregroundColor(.blue)
                    Button("Stop", action: stopBTScanning)
                        .buttonStyle(.bordered)
                        .foregroundColor(.blue)
                }
                .padding()
                
                DevicesList(btManager: bluetoothManager,
                            _devices: $bluetoothManager.devices)
            }
        }
        .onAppear {
            initBTManager()
        }
    }
    
    func initBTManager() {
        print("init BT manager")
        bluetoothManager.start()
    }

    func startBTScanning() {
        bluetoothManager.startScanning()
        isScanning = true
    }
    
    func stopBTScanning() {
        bluetoothManager.stopScanning()
        isScanning = false
    }
}

struct ScanStatus: View {
    var isScanning: Bool
    
    var body: some View {
        HStack {
            Text(isScanning ? "Scanning..." : "Not scanning")
        }
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
            Text("\(translateRssi(_: device.rssi))")
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
            return "???"
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
