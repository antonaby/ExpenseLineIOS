//
//  DatabaseManager.swift
//  ExpenseLineIOS
//
//  Created by Anton Abyshev on 27.03.24.
//

import Foundation
import CoreData

enum DatabaseManagerError: Error {
    
    case syncError(msg: String, reason: Error?)
    
}


class DatabaseManager: ObservableObject {
    
    private let container: NSPersistentContainer
    
    var viewContext: NSManagedObjectContext {
        get {
            container.viewContext
        }
    }
    
    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "DataContainer")
        
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        
        container.loadPersistentStores { (description, error) in
            if let error = error {
                fatalError("Failed to load persisten store \(error)")
            }
        }
    }
    
    func sync() throws {
        guard container.viewContext.hasChanges else { return }
        
        do {
            try container.viewContext.save()
        } catch {
            throw DatabaseManagerError.syncError(msg: "Failed to save CoreData context", reason: error)
        }
    }
    
    
    // TODO: remove
    func save() {
        guard container.viewContext.hasChanges else { return }
        
        do {
            try container.viewContext.save()
        } catch {
            fatalError("Failed to save data \(error)")
        }
    }
    
}
