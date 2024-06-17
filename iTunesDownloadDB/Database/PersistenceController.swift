//
//  DataController.swift
//  iTunesDownloadDB
//
//  Created by Sonkar, Swapnil on 21/05/24.
//

import CoreData
//TODO: Blob
let PCShared = PersistenceController.shared
let mainContext = PCShared.container.viewContext

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
    
    func save(context: NSManagedObjectContext = mainContext) throws {
        if context.hasChanges {
            try context.save()
        }
    }
    
    lazy var privateContext: NSManagedObjectContext = {
        return PCShared.container.newBackgroundContext()
    }()
    
}

extension PersistenceController {
    
    // 1a Fetch Request
    private func fetchRequest<E: NSManagedObject>(entity: E.Type, predicates: [NSPredicate] = [], sortDescriptors: [SortDescriptor<E>] = []) -> NSFetchRequest<any NSFetchRequestResult> {
        let fetchRequest = E.fetchRequest()
        fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        fetchRequest.sortDescriptors = sortDescriptors.map { NSSortDescriptor($0) }
        
        return fetchRequest
    }
    
    // 1b Fetch Request
    private func fetchRequest2(entityName: String, predicates: [NSPredicate] = [], sortId: String?) -> NSFetchRequest<NSManagedObject> {
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: entityName)
        fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        if let sortId = sortId {
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: sortId, ascending: true)]
        }
        
        return fetchRequest
    }
    
    // 2a Get Entity
    private func getEntity<E: NSManagedObject>(fetchRequest: NSFetchRequest<any NSFetchRequestResult>) -> [E] {
        do {
            return try mainContext.performAndWait {
                return try mainContext.fetch(fetchRequest) as? [E] ?? []
            }
        } catch {
            print(error.localizedDescription)
        }
        return []
    }
    
    // 2b Get Entity
    private func getEntity<E: NSManagedObject>(fetchRequest: NSFetchRequest<E>) -> [E] {
        do {
            return try mainContext.performAndWait {
                return try mainContext.fetch(fetchRequest)
            }
        } catch {
            print(error.localizedDescription)
        }
        return []
    }
    
    // 3 Get Entity and convert it into safeObjetct
    func getSafeObject<E, S>(entity: E.Type, predicates: [NSPredicate] = [], sortDescriptors: [SortDescriptor<E>] = []) -> [S] where E: NSManagedObject, E: SafeObjectType, S == E.SafeType {
        let fetchRequest = fetchRequest(entity: E.self, predicates: predicates, sortDescriptors: sortDescriptors)
        if let entities = getEntity(fetchRequest: fetchRequest) as? [E] {
            return entities.map {
                $0.toSafeObject()
            }
        }
        return []
    }
    
//    func deleteAllEntities() throws {
//        let entities = PCShared.container.managedObjectModel.entities
//        
//        for entity in entities {
//            _ = try await deleteEntityInBackgroundAlternative(entity: type(of: managedObject))
//        }
//        
//    }
    
    // 4a Delete Entity
    func deleteEntity<E: NSManagedObject>(entity: E.Type, predicates: [NSPredicate] = []) throws -> Bool {

        return try mainContext.performAndWait {
            let fetchRequest = fetchRequest(entity: E.self, predicates: predicates)
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            deleteRequest.resultType = .resultTypeObjectIDs
            
            let batchDelete = try mainContext.execute(deleteRequest) as? NSBatchDeleteResult

            guard let deleteResult = batchDelete?.result as? [NSManagedObjectID] else { return false }
            
            let deletedObjects: [AnyHashable: Any] = [NSDeletedObjectsKey: deleteResult]
            
            NSManagedObjectContext.mergeChanges(fromRemoteContextSave: deletedObjects, into: [mainContext])
            
            return deleteResult.isEmpty == false
        }
    }
    
    // 4b Delete Entity in background
    func deleteEntityInBackground<E: NSManagedObject>(entity: E.Type, predicates: [NSPredicate] = []) throws -> Bool {

        return try privateContext.performAndWait {
            let fetchRequest = fetchRequest(entity: entity.self, predicates: predicates)
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            deleteRequest.resultType = .resultTypeObjectIDs
            
            let batchDelete = try privateContext.execute(deleteRequest) as? NSBatchDeleteResult

            guard let deleteResult = batchDelete?.result as? [NSManagedObjectID] else { return false }
            
            let deletedObjects: [AnyHashable: Any] = [NSDeletedObjectsKey: deleteResult]
            
            NSManagedObjectContext.mergeChanges(fromRemoteContextSave: deletedObjects, into: [mainContext])
            
            return deleteResult.isEmpty == false
        }
    }
    
    // 4c Delete Entity in background
    func deleteEntityInBackgroundAlternative<E: NSManagedObject>(entity: E.Type, predicates: [NSPredicate] = []) async throws -> Bool {
        
        return try await PCShared.container.performBackgroundTask { context in
            let fetchRequest = self.fetchRequest(entity: entity.self, predicates: predicates)
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            deleteRequest.resultType = .resultTypeObjectIDs
            
            let batchDelete = try context.execute(deleteRequest) as? NSBatchDeleteResult

            guard let deleteResult = batchDelete?.result as? [NSManagedObjectID] else { return false }
            
            let deletedObjects: [AnyHashable: Any] = [NSDeletedObjectsKey: deleteResult]
            
            NSManagedObjectContext.mergeChanges(fromRemoteContextSave: deletedObjects, into: [mainContext])
            
            return deleteResult.isEmpty == false
        }
    }
}
