//
//  PeripheralView.swift
//  Bluetooth Test
//
//  Created by Gabriel Busto on 12/21/22.
//

import Foundation
import SwiftUI

struct PeripheralView: View {
    
    @ObservedObject var bluetoothManager: BluetoothManager
    
    public var uuid: UUID
    
    public var peripheralName: String
    
    var body: some View {
        VStack {
            Text("Speaking with peripheral \(peripheralName)")
                .font(.title)
                .foregroundColor(.green)
            
            Spacer()
            
            PeripheralOutputView(output: $bluetoothManager.peripheralOutput)
            
            PeripheralErrorView(error: $bluetoothManager.peripheralError)
            
            PeripheralMessageView(message: $bluetoothManager.lastMessage)
            
            Spacer()
            
            PeripheralCommandView(bluetoothManager: bluetoothManager, uuid: uuid)
            
            Spacer()
        }
        .onAppear {
            connectToPeripheral()
        }
        .onDisappear {
            disconnectFromPeripheral()
        }
    }
    
    func connectToPeripheral() {
        bluetoothManager.connectToPeripheral(uuid)
    }
    
    func disconnectFromPeripheral() {
        bluetoothManager.disconnectFromPeripheral(uuid)
    }
}

struct PeripheralCommandView: View {
    var bluetoothManager: BluetoothManager
    
    var uuid: UUID
    
    var body: some View {
        Button("Read RSSI", action: readPeripheralRSSI)
            .buttonStyle(.bordered)
            .foregroundColor(.blue)
        Button("Read Message", action: readMessage)
            .buttonStyle(.bordered)
            .foregroundColor(.blue)
    }
    
    func readPeripheralRSSI() {
        bluetoothManager.readPeripheralRSSI(uuid: uuid)
    }
    
    func readMessage() {
        bluetoothManager.readMessage(uuid: uuid)
    }
}

struct PeripheralOutputView: View {
    @Binding var output: String
    
    var body: some View {
        Text("Output: \(output)")
            .font(.body)
            .foregroundColor(.red)
            .multilineTextAlignment(.center)
    }
}

struct PeripheralErrorView: View {
    @Binding var error: String
    
    var body: some View {
        Text("error: \(error)")
            .font(.body)
            .foregroundColor(.red)
            .multilineTextAlignment(.center)
    }
}

struct PeripheralMessageView: View {
    @Binding var message: String
    
    var body: some View {
        Text("Last message: \(message)")
            .italic()
            .foregroundColor(.green)
            .multilineTextAlignment(.center)
    }
}

struct PeripheralView_Previews: PreviewProvider {
    static var previews: some View {
        PeripheralView(bluetoothManager: BluetoothManager(),
                       uuid: UUID(),
                       peripheralName: "Test Device")
    }
}
