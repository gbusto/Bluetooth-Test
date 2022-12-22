//
//  ContentView.swift
//  Bluetooth Test
//
//  Created by Gabriel Busto on 12/19/22.
//

import SwiftUI
import CoreData

struct MainView: View {
    
    var body: some View {
        NavigationView {
            VStack {
                VStack {
                    NavigationLink("Become the Central") {
                        CentralManagerView()
                    }
                    .padding()
                    
                    NavigationLink("Become the Peripheral") {
                        PeripheralManagerView()
                    }
                    .padding()
                }
                .padding()
            }
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
