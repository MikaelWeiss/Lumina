//
//  ChatService.swift
//  Lumina
//
//  Created by Mikael Weiss on 2/24/25.
//

import Foundation

class ClaudeAPIService: ChatServiceProtocol {
    private let apiKey: String
    private let baseURL = URL(string: "https://api.anthropic.com/v1/messages")!
    private let fileManager = FileManager.default
    private let conversationsURL: URL
    
    init(apiKey: String) {
        self.apiKey = apiKey
        
        // Set up storage for conversations
        let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        conversationsURL = documentsDirectory.appendingPathComponent("conversations.json")
    }
    
    func sendMessage(_ message: String, in conversation: Conversation) async throws -> Message {
        var request = URLRequest(url: baseURL)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("anthropic-version=2023-06-01", forHTTPHeaderField: "anthropic-version")
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "x-api-key")
        
        // Convert conversation messages to Claude API format
        let messages = conversation.messages.map { ["role": $0.role.rawValue, "content": $0.content] }
        
        // Prepare request body
        let requestBody: [String: Any] = [
            "model": "claude-3-opus-20240229",
            "messages": messages + [["role": "user", "content": message]],
            "max_tokens": 4000
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        
        // Send request
        let (data, response) = try await URLSession.shared.data(for: request)
        
        // Handle response
        guard let httpResponse = response as? HTTPURLResponse else {
            throw ChatError.invalidResponse
        }
        
        switch httpResponse.statusCode {
        case 200...299:
            // Success
            if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
               let content = (json["content"] as? [[String: Any]])?.first?["text"] as? String {
                return Message(role: .assistant, content: content)
            } else {
                throw ChatError.decodingError(NSError(domain: "ChatService", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to decode response"]))
            }
        case 401:
            throw ChatError.unauthorized
        case 429:
            throw ChatError.rateLimited
        default:
            throw ChatError.apiError("API error with status code: \(httpResponse.statusCode)")
        }
    }
    
    func createConversation(title: String) -> Conversation {
        var conversation = Conversation(title: title)
        
        let systemMessage = Message(role: .system, content: "Welcome to Lumi!")
        conversation.messages.append(systemMessage)
        
        return conversation
    }
    
    func saveConversation(_ conversation: Conversation) throws {
        var conversations = try loadConversations()
        
        if let index = conversations.firstIndex(where: { $0.id == conversation.id }) {
            conversations[index] = conversation
        } else {
            conversations.append(conversation)
        }
        
        let data = try JSONEncoder().encode(conversations)
        try data.write(to: conversationsURL)
    }
    
    func loadConversations() throws -> [Conversation] {
        guard fileManager.fileExists(atPath: conversationsURL.path) else {
            return []
        }
        
        let data = try Data(contentsOf: conversationsURL)
        return try JSONDecoder().decode([Conversation].self, from: data)
    }
    
    func deleteConversation(_ conversation: Conversation) throws {
        var conversations = try loadConversations()
        conversations.removeAll(where: { $0.id == conversation.id })
        
        let data = try JSONEncoder().encode(conversations)
        try data.write(to: conversationsURL)
    }
    
    func updateConversationTitle(_ conversation: Conversation, newTitle: String) throws -> Conversation {
        var updatedConversation = conversation
        updatedConversation.title = newTitle
        updatedConversation.updatedAt = Date()
        
        try saveConversation(updatedConversation)
        return updatedConversation
    }
    
    func validateAPIKey() async throws -> Bool {
        var request = URLRequest(url: baseURL)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("anthropic-version=2023-06-01", forHTTPHeaderField: "anthropic-version")
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "x-api-key")
        
        // Minimal request to check API key validity
        let requestBody: [String: Any] = [
            "model": "claude-3-opus-20240229",
            "messages": [["role": "user", "content": "Hello"]],
            "max_tokens": 1
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        
        do {
            let (_, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                return false
            }
            
            return httpResponse.statusCode == 200
        } catch {
            throw ChatError.networkError(error)
        }
    }
}
