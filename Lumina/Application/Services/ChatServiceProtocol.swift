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
    func sendMessage(for conversation: Conversation) async throws -> Message
    
    /// Create a new conversation
    func createConversation(title: String) -> Conversation
    
    /// Get API key status
    func validateAPIKey() async throws -> Bool
}
