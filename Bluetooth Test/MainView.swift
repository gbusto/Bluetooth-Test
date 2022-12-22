//
//  ContentView.swift
//  Bluetooth Test
//
//  Created by Gabriel Busto on 12/19/22.
//

import SwiftUI
import CoreData

struct MainView: View {
    
    @ObservedObject var bluetoothManager: BluetoothManager = BluetoothManager()
    @ObservedObject var peripheralManager: PeripheralManager = PeripheralManager()
    
    @State var message: String = ""
    
    var body: some View {
        VStack {
            /*
            NavigationLink("Become the Central") {
                CentralManagerView()
            }
            .padding()
            
            NavigationLink("Become the Peripheral") {
                PeripheralManagerView()
            }
            .padding()
            */
            
            StateButton(state: $peripheralManager.isAdvertising,
                        activeText: "Stop advertising",
                        inactiveText: "Start advertising",
                        action: changeAdvertisingState)
            StateButton(state: $bluetoothManager.isScanning,
                        activeText: "Stop scanning",
                        inactiveText: "Start scanning",
                        action: changeScanningState)
            
            ScrollView {
                
            }
            .border(.red)
            
            TextField("Enter message here", text: $message)
                .multilineTextAlignment(.center)
                .onSubmit {
                    print("New message: \(self.message)")
                    self.message = ""
                }
                .padding()
            
            Spacer()
        }
        .onAppear {
            bluetoothManager.start()
            peripheralManager.start()
        }
    }
    
    func changeAdvertisingState() {
        if peripheralManager.isAdvertising {
            peripheralManager.stopAdvertising()
        }
        else {
            peripheralManager.startAdvertising()
        }
    }
    
    func changeScanningState() {
        if bluetoothManager.isScanning {
            bluetoothManager.stopScanning()
        }
        else {
            bluetoothManager.startScanning()
        }
    }
}

struct StateButton: View {
    @Binding var state: Bool
    
    var activeText: String
    var inactiveText: String
    
    var action: () -> Void
    
    var body: some View {
        Button(state ? activeText : inactiveText, action: action)
            .buttonStyle(.bordered)
            .foregroundColor(.blue)
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
