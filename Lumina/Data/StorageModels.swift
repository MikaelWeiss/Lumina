//
//  StorageModels.swift
//  Lumina
//
//  Created by Mikael Weiss on 2/24/25.
//

import Foundation
import SwiftData

@Model
class StorageConversation: Identifiable {
    private(set) var id = UUID()
    var title = ""
    var messages = [Message]()
    var createdAt = Date.now
    var updatedAt = Date.now
    
    init(id: UUID = UUID(),
         title: String = "New Conversation",
         messages: [Message] = [],
         createdAt: Date = Date()) {
        self.id = id
        self.title = title
        self.messages = messages
        self.createdAt = createdAt
        self.updatedAt = createdAt
    }
    
    struct Message: Identifiable, Codable {
        let id: UUID
        let role: MessageRole
        let content: String
        let timestamp: Date
        
        init(id: UUID = UUID(),
             role: MessageRole,
             content: String,
             timestamp: Date = Date()) {
            self.id = id
            self.role = role
            self.content = content
            self.timestamp = timestamp
        }
    }
}
