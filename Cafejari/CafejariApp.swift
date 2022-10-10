//
//  CafejariApp.swift
//  Cafejari
//
//  Created by 안용우 on 2022/10/10.
//

import SwiftUI

@main
struct CafejariApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
