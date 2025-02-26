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
    @Relationship(deleteRule: .cascade) var messages: [StorageMessage] = []
    var createdAt = Date.now
    var updatedAt = Date.now
    
    init(id: UUID = UUID(),
         title: String = "New Conversation",
         messages: [StorageMessage] = [],
         createdAt: Date = Date()) {
        self.id = id
        self.title = title
        self.messages = messages
        self.createdAt = createdAt
        self.updatedAt = createdAt
    }
    
    // Convert to domain model
    func toDomainModel() -> Conversation {
        return Conversation(
            id: id,
            title: title,
            messages: messages.map { $0.toDomainModel() }.sorted(by: { $0.timestamp < $1.timestamp }),
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }
    
    // Create from domain model
    static func fromDomainModel(_ conversation: Conversation) -> StorageConversation {
        let storageConversation = StorageConversation(
            id: conversation.id,
            title: conversation.title,
            messages: conversation.messages.map { StorageMessage.fromDomainModel($0) },
            createdAt: conversation.createdAt
        )
        storageConversation.updatedAt = conversation.updatedAt
        return storageConversation
    }
}

@Model
class StorageMessage: Identifiable {
    private(set) var id = UUID()
    var role: String
    var content: String
    var timestamp = Date.now
    
    init(id: UUID = UUID(),
         role: String,
         content: String,
         timestamp: Date = Date()) {
        self.id = id
        self.role = role
        self.content = content
        self.timestamp = timestamp
    }
    
    // Convert to domain model
    func toDomainModel() -> Message {
        return Message(
            id: id,
            role: MessageRole(rawValue: role) ?? .user,
            content: content,
            timestamp: timestamp
        )
    }
    
    // Create from domain model
    static func fromDomainModel(_ message: Message) -> StorageMessage {
        return StorageMessage(
            id: message.id,
            role: message.role.rawValue,
            content: message.content,
            timestamp: message.timestamp
        )
    }
}
