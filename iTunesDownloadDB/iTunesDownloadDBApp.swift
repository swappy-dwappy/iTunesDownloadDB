//
//  iTunesDownloadDBApp.swift
//  iTunesDownloadDB
//
//  Created by Sonkar, Swapnil on 20/05/24.
//

import SwiftUI

@main
struct iTunesDownloadDBApp: App {
    
    @StateObject private var persistenceController = PersistenceController.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
