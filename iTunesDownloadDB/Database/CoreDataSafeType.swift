//
//  CoreDataSafeType.swift
//  iTunesDownloadDB
//
//  Created by Sonkar, Swapnil on 08/06/24.
//

import CoreData

protocol SafeObjectType: NSManagedObject {
    
    associatedtype SafeType
    associatedtype ManagedType: NSManagedObject
    
    static func create(safe: SafeType) -> ManagedType
    func toSafeObject() -> SafeType
}
