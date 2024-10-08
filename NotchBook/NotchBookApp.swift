//
//  NotchBookApp.swift
//  NotchBook
//
//  Created by Guruprasad Meena on 08/10/24.
//

import SwiftUI

@main
struct NotchBookApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
