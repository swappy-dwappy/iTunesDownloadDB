//
//  CoreDataPersistableType.swift
//  iTunesDownloadDB
//
//  Created by Sonkar, Swapnil on 26/05/24.
//

import CoreData

protocol UUIDIdentifiable: Identifiable {
    var id: Int? { get set }
}

protocol CoreDataPersistableType: UUIDIdentifiable {
    //1
    associatedtype ManagedType
    
    //2
    init()
    
    //3
    init(managedObject: ManagedType?)
    
    //4
    var keyMap: [PartialKeyPath<Self>: String] { get }
    
    //5
    mutating func toManagedObject(context: NSManagedObjectContext) -> ManagedType
    
    //6
    func save(context: NSManagedObjectContext) throws
}

extension CoreDataPersistableType where ManagedType: NSManagedObject {
    
    init(managedObject: ManagedType?) {
        self.init()
        
        guard let managedObject else { return }
        
        for attribute in managedObject.entity.attributesByName {
            if let keyP = keyMap.first(where: { $0.value == attribute.key })?.key {
                let value = managedObject.value(forKey: attribute.key)
                storeValue(value, toKeyPath: keyP)
            }
        }
    }
    
    private mutating func storeValue(_ value: Any?,
      toKeyPath partial: AnyKeyPath) {
      switch partial {
      case let keyPath as WritableKeyPath<Self, URL?>:
        self[keyPath: keyPath] = value as? URL
      case let keyPath as WritableKeyPath<Self, Int?>:
        self[keyPath: keyPath] = value as? Int
      case let keyPath as WritableKeyPath<Self, String?>:
        self[keyPath: keyPath] = value as? String
      case let keyPath as WritableKeyPath<Self, Bool?>:
        self[keyPath: keyPath] = value as? Bool
      case let keyPath as WritableKeyPath<Self, Double?>:
          self[keyPath: keyPath] = value as? Double
      case let keyPath as WritableKeyPath<Self, Date?>:
          self[keyPath: keyPath] = value as? Date
      default:
        return
      }
    }
    
    mutating func toManagedObject(context: NSManagedObjectContext = PersistenceController.shared.container.viewContext) -> ManagedType {
        let persistedValue: ManagedType
        if let id = self.id {
            let fetchRequest = ManagedType.fetchRequest()
            fetchRequest.predicate = NSPredicate(
                format: "id = %@", id as CVarArg)
            if let results = try? context.fetch(fetchRequest),
               let firstResult = results.first as? ManagedType {
                persistedValue = firstResult
            } else {
                persistedValue = ManagedType.init(context: context)
                self.id = persistedValue.value(forKey: "id") as? Int
            }
        } else {
            persistedValue = ManagedType.init(context: context)
            self.id = persistedValue.value(forKey: "id") as? Int
        }

        return setValuesFromMirror(persistedValue: persistedValue)
    }
    
    private func setValuesFromMirror(persistedValue: ManagedType) -> ManagedType {
      let mirror = Mirror(reflecting: self)
      for case let (label?, value) in mirror.children {
        let value2 = Mirror(reflecting: value)
        if value2.displayStyle != .optional || !value2.children.isEmpty {
          persistedValue.setValue(value, forKey: label)
        }
      }

      return persistedValue
    }
    
    func save(context: NSManagedObjectContext = PersistenceController.shared.container.viewContext) throws {
      try context.save()
    }
}
