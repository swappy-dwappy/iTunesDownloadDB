//
//  DataController.swift
//  iTunesDownloadDB
//
//  Created by Sonkar, Swapnil on 21/05/24.
//

import CoreData

let PCShared = PersistenceController.shared
let mainContext = PersistenceController.shared.container.viewContext

class PersistenceController: ObservableObject {
    static let shared = PersistenceController()
    
    let container = NSPersistentContainer(name: "iTunesDownloadDB")
    
    init() {
        container.loadPersistentStores { NSEntityDescription, error in
            if let error {
                print("Core Data failed to load: \(error.localizedDescription)")
            }
        }
        
        self.container.viewContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
        self.container.viewContext.automaticallyMergesChangesFromParent = true
    }
    
    func saveContext() throws {
        if mainContext.hasChanges {
            try mainContext.save()
        }
    }
    
    lazy var privateContext: NSManagedObjectContext = {
        return PersistenceController.shared.container.newBackgroundContext()
    }()
    
}

extension PersistenceController {
    
    func getEntity<E: NSManagedObject>() -> [E] {
        let fetchRequest = E.fetchRequest()
        do {
            return try mainContext.fetch(fetchRequest) as? [E] ?? []
        } catch {
            print(error.localizedDescription)
        }
        return []
    }
    
    func getSafeObject<E, S>(entity: E.Type) -> [S] where E: NSManagedObject, E: SafeObjectType, S == E.SafeType {
        let entities = getEntity() as [E]
        return entities.map {
            $0.toSafeObject()
        }
    }
    
    
    func deleteAllEntities() {
    }
    
    func deleteEntity(entityName: String) throws {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)        
        try mainContext.execute(deleteRequest)
    }
    
    func deleteEntityInBackground(entityName: String) throws {

        try privateContext.performAndWait {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            deleteRequest.resultType = .resultTypeObjectIDs

            let batchDelete = try privateContext.execute(deleteRequest) as? NSBatchDeleteResult

            guard let deleteResult = batchDelete?.result as? [NSManagedObjectID] else { return }
            
            let deletedObjects: [AnyHashable: Any] = [NSDeletedObjectsKey: deleteResult]
            
            NSManagedObjectContext.mergeChanges(fromRemoteContextSave: deletedObjects, into: [mainContext])
        }
    }
    
    func deleteEntityInBackgroundAlternative(entityName: String) async throws {
        
        try await PCShared.container.performBackgroundTask { context in
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            deleteRequest.resultType = .resultTypeObjectIDs
            
            let batchDelete = try context.execute(deleteRequest) as? NSBatchDeleteResult

            guard let deleteResult = batchDelete?.result as? [NSManagedObjectID] else { return }
            
            let deletedObjects: [AnyHashable: Any] = [NSDeletedObjectsKey: deleteResult]
            
            NSManagedObjectContext.mergeChanges(fromRemoteContextSave: deletedObjects, into: [mainContext])
        }
    }
}
