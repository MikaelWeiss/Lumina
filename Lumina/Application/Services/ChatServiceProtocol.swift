//
//  ChatServiceProtocol.swift
//  Lumina
//
//  Created by Mikael Weiss on 2/24/25.
//

import Foundation

// MARK: - Protocol

protocol ChatServiceProtocol {
    /// Send a message to the Claude API and receive a response
    func sendMessage(_ message: String, in conversation: Conversation) async throws -> Message
    
    /// Create a new conversation
    func createConversation(title: String) -> Conversation
    
    /// Save a conversation
    func saveConversation(_ conversation: Conversation) throws
    
    /// Load all saved conversations
    func loadConversations() throws -> [Conversation]
    
    /// Delete a conversation
    func deleteConversation(_ conversation: Conversation) throws
    
    /// Update conversation title
    func updateConversationTitle(_ conversation: Conversation, newTitle: String) throws -> Conversation
    
    /// Get API key status
    func validateAPIKey() async throws -> Bool
}
