//
//  Book_FinderApp.swift
//  Book Finder
//
//  Created by Admin on 10/09/25.
//

import SwiftUI

@main
struct Book_FinderApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
