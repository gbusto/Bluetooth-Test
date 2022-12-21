//
//  PeripheralView.swift
//  Bluetooth Test
//
//  Created by Gabriel Busto on 12/20/22.
//

import Foundation
import SwiftUI

struct PeripheralView: View {
    @ObservedObject private var peripheralManager: PeripheralManager = PeripheralManager()
    
    var body: some View {
        VStack {
            Text("You are now the Peripheral/Server")
                .font(.title)
                .foregroundColor(.green)
                .padding()
            
            PeripheralAdvertisingView(isAdvertising: $peripheralManager.isAdvertising)
            
            PeripheralStateView(state: $peripheralManager.state)
            
            PeripheralErrorView(error: $peripheralManager.error)
                                    
            PeripheralCommandView(peripheralManager: peripheralManager)
            
            Spacer()
        }
        .onAppear {
            peripheralManager.start()
        }
    }
}

struct PeripheralCommandView: View {
    var peripheralManager: PeripheralManager
    
    var body: some View {
        Button("Start Advertising", action: startBTAdvertising)
            .buttonStyle(.bordered)
            .foregroundColor(.blue)
        Button("Stop Advertising", action: stopBTAdvertising)
            .buttonStyle(.bordered)
            .foregroundColor(.blue)
    }
    
    func startBTAdvertising() {
        peripheralManager.startAdvertising()
    }
    
    func stopBTAdvertising() {
            peripheralManager.stopAdvertising()
    }
}

struct PeripheralAdvertisingView: View {
    @Binding var isAdvertising: Bool
    
    var body: some View {
        Text(isAdvertising ? "Adversiting" : "Not advertising")
            .font(.body)
            .foregroundColor(.red)
            .multilineTextAlignment(.center)
    }
}

struct PeripheralStateView: View {
    @Binding var state: String
    
    var body: some View {
        Text("Peripheral state: \(state)")
            .font(.body)
            .foregroundColor(.red)
            .multilineTextAlignment(.center)
    }
}

struct PeripheralErrorView: View {
    @Binding var error: String
    
    var body: some View {
        Text("Peripheral error: \(error)")
            .font(.body)
            .foregroundColor(.red)
            .multilineTextAlignment(.center)
    }
}

struct PeripheralView_Previews: PreviewProvider {
    static var previews: some View {
        PeripheralView()
    }
}
