//
//  ContentView.swift
//  Bluetooth Test
//
//  Created by Gabriel Busto on 12/19/22.
//

import SwiftUI
import CoreData

struct ContentView: View {
    
    var body: some View {
        NavigationView {
            VStack {
                VStack {
                    NavigationLink("Become the Central") {
                        CentralView()
                    }
                    .padding()
                    
                    NavigationLink("Become the Peripheral") {
                        PeripheralView()
                    }
                    .padding()
                }
                .padding()
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
