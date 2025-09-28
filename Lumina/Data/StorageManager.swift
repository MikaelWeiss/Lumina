//
//  StorageManager.swift
//  Lumina
//
//  Created by Mikael Weiss on 9/27/25.
//

import Foundation
import SwiftData

@MainActor
class StorageManager {
    static let shared = StorageManager()

    let container: ModelContainer

    private init() {
        let schema = Schema([
            Conversation.self,
            Message.self,
            MessageAttachment.self,
            Provider.self,
            LLM.self
        ])

        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            container = try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }
}