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
            let _ = print("\n+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++")
            let _ = print("Documents Directory: ", FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask).last ?? "Not Found!")
            let _ = print("+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n")

            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
