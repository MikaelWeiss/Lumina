//
//  MockChatService.swift
//  Lumina
//
//  Created by Mikael Weiss on 2/24/25.
//

import Foundation
import Combine

class MockChatService: ChatServiceProtocol {
    private let mockDelay: TimeInterval = 1.5
    
    func sendMessage(for conversation: Conversation) async throws -> Message {
        // Simulate network delay
        try await Task.sleep(for: .seconds(mockDelay))
        guard let message = conversation.messages.last?.content else { throw ChatError.missingMessage }
        
        // Create a mock response based on the message content
        let responseContent: String
        if message.lowercased().contains("hello") || message.lowercased().contains("hi") {
            responseContent = "Hello! How can I help you today?"
        } else if message.lowercased().contains("swift") {
            responseContent = "Swift is a powerful programming language developed by Apple. It's designed to be safe, fast, and expressive."
        } else if message.lowercased().contains("swiftui") {
            responseContent = "SwiftUI is Apple's declarative framework for building user interfaces across all Apple platforms."
        } else {
            responseContent = "That's an interesting question. I'd be happy to explore this topic further with you."
        }
        
        // Create the assistant message
        let assistantMessage = Message(id: UUID(), role: .assistant, content: responseContent, timestamp: Date())
        
        return assistantMessage
    }
    
    func createConversation(title: String) -> Conversation {
        Conversation(id: UUID(), title: title, messages: [])
    }
    
    func validateAPIKey() async throws -> Bool {
        // Mock API key validation
        return true
    }
} 
