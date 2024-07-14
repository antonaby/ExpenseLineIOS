//
//  DatabaseManager.swift
//  ExpenseLineIOS
//
//  Created by Anton Abyshev on 27.03.24.
//

import Foundation
import CoreData

enum DatabaseManagerError: Error {
    
    case SyncError(msg: String, reason: Error?)
    
}


class DatabaseManager: ObservableObject {
    
    private var container: NSPersistentCloudKitContainer
    
    var viewContext: NSManagedObjectContext {
        get {
            container.viewContext
        }
    }
    
    init() {
        container = NSPersistentCloudKitContainer(name: "DataContainer")
    }
    
    func initializeStore(inMemory: Bool = false) {
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        
        container.loadPersistentStores { (description, error) in
            if let error = error {
                fatalError("Failed to load persisten store \(error)")
            }
        }
        
        initCloudKitSchema()
    }
    
    private func initCloudKitSchema() {
        #if DEBUG
        if !CommandLine.arguments.contains("-init-cloudkit-scheme") {
            return
        }
        
        do {
            try container.initializeCloudKitSchema(options: [])
        } catch {
            print("Something went wrong \(error)")
        }
        #endif
    }
    
    func sync() throws {
        guard container.viewContext.hasChanges else { return }
        
        do {
            try container.viewContext.save()
        } catch {
            throw DatabaseManagerError.SyncError(msg: "Failed to save CoreData context", reason: error)
        }
    }
    
    func rollback() {
        guard container.viewContext.hasChanges else { return }
        container.viewContext.rollback()
    }
    
}
