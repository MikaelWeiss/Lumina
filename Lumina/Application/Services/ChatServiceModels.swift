//
//  ChatServiceModels.swift
//  Lumina
//
//  Created by Mikael Weiss on 2/25/25.
//

import Foundation

struct Message: Identifiable, Codable {
    let id: UUID
    let role: MessageRole
    let content: String
    let timestamp: Date
    
    init(id: UUID = UUID(), role: MessageRole, content: String, timestamp: Date = Date()) {
        self.id = id
        self.role = role
        self.content = content
        self.timestamp = timestamp
    }
    
    var isUserMessage: Bool {
        role == .user
    }
}

enum MessageRole: String, Codable {
    case user
    case assistant
}

struct Conversation: Identifiable, Codable {
    let id: UUID
    var title: String
    var messages: [Message]
    var createdAt: Date
    var updatedAt: Date
    
    init(id: UUID = UUID(), title: String = "New Conversation", messages: [Message] = [], createdAt: Date = Date()) {
        self.id = id
        self.title = title
        self.messages = messages
        self.createdAt = createdAt
        self.updatedAt = createdAt
    }
}

enum ChatError: Error {
    case networkError(Error)
    case invalidResponse
    case apiError(String)
    case decodingError(Error)
    case unauthorized
    case rateLimited
    case unknown
    case conversationNotFound
    case missingMessage
}
