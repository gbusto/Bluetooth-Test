//
//  ContentView.swift
//  Bluetooth Test
//
//  Created by Gabriel Busto on 12/19/22.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @ObservedObject var bluetoothManager: BluetoothManager = BluetoothManager()
    var peripheralManager: PeripheralManager = PeripheralManager()
    
    @State var stateString: String = "Waiting"
    
    var body: some View {
        NavigationView {
            VStack {
                VStack {
                    StateView(stateString: $stateString)
                        .padding()
                    
                    NavigationLink("Become the Central") {
                        CentralView()
                    }
                    Button("Start Advertising", action: startBTAdvertising)
                        .buttonStyle(.bordered)
                        .foregroundColor(.blue)
                    Button("Stop Advertising", action: stopBTAdvertising)
                        .buttonStyle(.bordered)
                        .foregroundColor(.blue)
                }
                .padding()
            }
        }
    }
    
    func initBTManager() {
        print("init BT manager")
    }
    
    func startBTAdvertising() {
        peripheralManager.start()
        peripheralManager.startAdvertising()
        stateString = "Advertising..."
    }
    
    func stopBTAdvertising() {
        peripheralManager.stopAdvertising()
        stateString = "Waiting"
    }
}

struct StateView: View {
    @Binding var stateString: String
    
    var body: some View {
        HStack {
            Text(stateString)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
