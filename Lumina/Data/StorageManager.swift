//
//  StorageManager.swift
//  Lumina
//
//  Created by Mikael Weiss on 2/24/25.
//

import Foundation
import SwiftData

@MainActor
class StorageManager {
    
    static let shared = StorageManager()
    
    let container: ModelContainer
    
    var mainContext: ModelContext {
        container.mainContext
    }
    
    init() {
        do {
            //#if DEBUG
            //            container = PreviewData.sharedContext()
            //#else
            container = try ModelContainer(for: StorageConversation.self, StorageMessage.self)
            //#endif
        } catch {
            fatalError("Could not initialize the data model container.")
        }
    }
}

extension StorageManager {
    func insert<T>(_ model: T) where T: PersistentModel {
        mainContext.insert(model)
        try? mainContext.save()
    }
    
    func fetch<T>(_ descriptor: FetchDescriptor<T>) -> [T] where T: PersistentModel {
        let models = try? mainContext.fetch(descriptor)
        return models ?? []
    }
    
    func delete<T>(_ model: T) where T: PersistentModel {
        mainContext.delete(model)
        try? mainContext.save()
    }
    
    func save() throws {
        try mainContext.save()
    }
}
