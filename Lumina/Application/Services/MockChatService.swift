//
//  MockChatService.swift
//  Lumina
//
//  Created by Mikael Weiss on 2/24/25.
//

import Foundation
import Combine

class MockChatService: ChatServiceProtocol {
    private var conversations: [Conversation] = []
    private let mockDelay: TimeInterval = 1.5
    
    init() {
        // Create some sample conversations for preview
        let sampleConversation1 = Conversation(id: UUID(), title: "Swift Programming", messages: [
            Message(id: UUID(), role: .user, content: "How do I use async/await in Swift?", timestamp: Date().addingTimeInterval(-3600)),
            Message(id: UUID(), role: .assistant, content: "Here is some mach data", timestamp: Date().addingTimeInterval(-3590))
        ])
        
        let sampleConversation2 = Conversation(id: UUID(), title: "SwiftUI Tips", messages: [
            Message(id: UUID(), role: .user, content: "What's the best way to manage state in SwiftUI?", timestamp: Date().addingTimeInterval(-7200)),
            Message(id: UUID(), role: .assistant, content: "SwiftUI offers several state management options:\n\n1. `@State` - For simple local component state\n2. `@Binding` - To create a two-way connection to state\n3. `@ObservedObject` - For external reference types that conform to ObservableObject\n4. `@EnvironmentObject` - For dependency injection across the view hierarchy\n5. `@StateObject` - Similar to ObservedObject but with guaranteed lifecycle\n\nFor complex apps, consider combining these with architecture patterns like MVVM or using dedicated state management libraries.", timestamp: Date().addingTimeInterval(-7180))
        ])
        
        conversations = [sampleConversation1, sampleConversation2]
    }
    
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
    
    func saveConversation(_ conversation: Conversation) throws {
        if let index = conversations.firstIndex(where: { $0.id == conversation.id }) {
            conversations[index] = conversation
        } else {
            conversations.append(conversation)
        }
    }
    
    func loadConversations() throws -> [Conversation] {
        conversations
    }
    
    func deleteConversation(_ conversation: Conversation) throws {
        conversations.removeAll(where: { $0.id == conversation.id })
    }
    
    func updateConversationTitle(_ conversation: Conversation, newTitle: String) throws -> Conversation {
        guard let index = conversations.firstIndex(where: { $0.id == conversation.id }) else {
            throw ChatError.conversationNotFound
        }
        
        var updatedConversation = conversation
        updatedConversation.title = newTitle
        conversations[index] = updatedConversation
        
        return updatedConversation
    }
    
    func validateAPIKey() async throws -> Bool {
        // Simulate network delay
        try await Task.sleep(for: .seconds(mockDelay))
        
        // Always return true for mock service
        return true
    }
} 
