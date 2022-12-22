//
//  PeripheralView.swift
//  Bluetooth Test
//
//  Created by Gabriel Busto on 12/20/22.
//

import Foundation
import SwiftUI

struct PeripheralManagerView: View {
    @ObservedObject private var peripheralManager: PeripheralManager = PeripheralManager()
    
    @State var message: String = ""
    
    var body: some View {
        VStack {
            Text("You are now the Peripheral/Server")
                .font(.title)
                .foregroundColor(.green)
                .padding()
            
            PeripheralManagerAdvertisingView(isAdvertising: $peripheralManager.isAdvertising)
            
            PeripheralManagerStateView(state: $peripheralManager.state)
            
            PeripheralManagerErrorView(error: $peripheralManager.error)
                                    
            PeripheralManagerCommandView(peripheralManager: peripheralManager,
                                         message: $message)
            
            Spacer()
        }
        .onAppear {
            peripheralManager.start()
        }
    }
}

struct PeripheralManagerCommandView: View {
    var peripheralManager: PeripheralManager
    
    @Binding var message: String
    
    var body: some View {
        VStack {
            Button("Start Advertising", action: startBTAdvertising)
                .buttonStyle(.bordered)
                .foregroundColor(.blue)
            Button("Stop Advertising", action: stopBTAdvertising)
                .buttonStyle(.bordered)
                .foregroundColor(.blue)
            TextField("Message", text: $message)
                .multilineTextAlignment(.center)
                .onSubmit {
                    peripheralManager.updateServices(message)
                }
        }
    }
    
    func startBTAdvertising() {
        peripheralManager.updateServices()
        peripheralManager.startAdvertising()
    }
    
    func stopBTAdvertising() {
            peripheralManager.stopAdvertising()
    }
}

struct PeripheralManagerAdvertisingView: View {
    @Binding var isAdvertising: Bool
    
    var body: some View {
        Text(isAdvertising ? "Adversiting" : "Not advertising")
            .font(.body)
            .foregroundColor(.red)
            .multilineTextAlignment(.center)
    }
}

struct PeripheralManagerStateView: View {
    @Binding var state: String
    
    var body: some View {
        Text("Peripheral state: \(state)")
            .font(.body)
            .foregroundColor(.red)
            .multilineTextAlignment(.center)
    }
}

struct PeripheralManagerErrorView: View {
    @Binding var error: String
    
    var body: some View {
        Text("Peripheral error: \(error)")
            .font(.body)
            .foregroundColor(.red)
            .multilineTextAlignment(.center)
    }
}

struct PeripheralManagerView_Previews: PreviewProvider {
    static var previews: some View {
        PeripheralManagerView()
    }
}
