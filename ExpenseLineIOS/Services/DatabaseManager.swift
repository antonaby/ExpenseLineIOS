//
//  DatabaseManager.swift
//  ExpenseLineIOS
//
//  Created by Anton Abyshev on 27.03.24.
//

import Foundation
import CoreData


class DatabaseManager: ObservableObject {
    
    public static let shared = DatabaseManager(inMemory: true)
    
    private let container: NSPersistentContainer
    
    var viewContext: NSManagedObjectContext {
        get {
            container.viewContext
        }
    }
    
    init(inMemory: Bool = false) {
        self.container = NSPersistentContainer(name: "DataContainer")
        
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        self.container.loadPersistentStores { (description, error) in
            if let error = error {
                fatalError("Failed to load persisten store \(error)")
            }
        }
    }
    
    func save() {
        guard container.viewContext.hasChanges else { return }
        
        do {
            try container.viewContext.save()
        } catch {
            fatalError("Failed to save data \(error)")
        }
    }
    
}
