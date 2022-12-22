//
//  Bluetooth_TestApp.swift
//  Bluetooth Test
//
//  Created by Gabriel Busto on 12/19/22.
//

import SwiftUI

@main
struct Bluetooth_TestApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            MainView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
