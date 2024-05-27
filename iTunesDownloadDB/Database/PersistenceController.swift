//
//  DataController.swift
//  iTunesDownloadDB
//
//  Created by Sonkar, Swapnil on 21/05/24.
//

import CoreData

class PersistenceController: ObservableObject {
    static let shared = PersistenceController()
    
    let container = NSPersistentContainer(name: "iTunesDownloadDBApp")
    
    init() {
        container.loadPersistentStores { NSEntityDescription, error in
            if let error {
                print("Core Data failed to load: \(error.localizedDescription)")
            }
        }
        
        self.container.viewContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
        self.container.viewContext.automaticallyMergesChangesFromParent = true
    }
}
