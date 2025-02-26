//
//  ChatService.swift
//  Lumina
//
//  Created by Mikael Weiss on 2/24/25.
//

import Foundation

class ClaudeAPIService: ChatServiceProtocol {
    private let baseURL = URL(string: "https://api.anthropic.com/v1/messages")!
    private let fileManager = FileManager.default
    private let conversationsURL: URL
    
    init() {
        // Set up storage for conversations in app group's Application Support folder
        guard let containerURL = fileManager.containerURL(forSecurityApplicationGroupIdentifier: "group.org.weisssolutions.lumina") else {
            fatalError("Failed to get app group container URL")
        }
        
        let appSupportURL = containerURL.appendingPathComponent("Library/Application Support", isDirectory: true)
        
        // Create directory if it doesn't exist
        if !fileManager.fileExists(atPath: appSupportURL.path) {
            do {
                try fileManager.createDirectory(at: appSupportURL, withIntermediateDirectories: true)
            } catch {
                print("Error creating Application Support directory: \(error)")
            }
        }
        
        conversationsURL = appSupportURL.appendingPathComponent("conversations.json")
    }
    
    func sendMessage(for conversation: Conversation) async throws -> Message {
        var request = URLRequest(url: baseURL)
        request.httpMethod = "POST"
        request.addValue("\(apiKey)", forHTTPHeaderField: "x-api-key")
        request.addValue("2023-06-01", forHTTPHeaderField: "anthropic-version")
        request.addValue("application/json", forHTTPHeaderField: "content-type")
        
        // Convert conversation messages to Claude API format
        let messages = conversation.messages.map { ["role": $0.role.rawValue, "content": $0.content] }
        
        // Prepare request body
        let requestBody: [String: Any] = [
            "model": "claude-3-5-haiku-20241022",
            "system": "You are Lumina, an AI assistant dedicated to helping users live more intentionally and achieve their personal and professional goals. Your purpose is to guide, support, and empower users on their journey toward a more purposeful life. RESPONSE FORMAT: - Always begin with exactly one thoughtful sentences that address the user's question or concern. - After your one sentences, provide EITHER: * Two clear, specific actionable steps the user should take next (one sentance per action), OR * Two focused clarifying questions to better understand the user's situation (also only one sentance per question). Only expand beyond this format when absolutely necessary to deliver essential information that cannot be condensed (such as walking through a values clarification exercise or explaining a complex concept). CORE IDENTITY AND APPROACH: - You are warm, encouraging, and empathetic, but also practical and focused on actionable steps. - You help users clarify their values, set meaningful goals, establish productive habits, and overcome obstacles. - You balance optimism with realism, acknowledging challenges while maintaining a growth mindset. - You personalize your guidance based on each user's unique circumstances, values, and goals. KEY CAPABILITIES: 1. Goal Setting: Help users define clear, meaningful, and achievable goals using the SMART framework. 2. Values Clarification: Guide users to identify their core values and align their goals with these values. 3. Habit Formation: Provide evidence-based strategies for building positive habits and breaking unproductive ones. 4. Productivity Systems: Offer guidance on time management and prioritization tailored to the user's style. 5. Motivation and Accountability: Help users stay motivated, track progress, and maintain accountability. 6. Reflection and Adjustment: Encourage regular reflection and help users adjust their approach as needed. INTERACTION GUIDELINES: - Ask thoughtful questions to understand the user's specific situation before offering advice. - Provide concise, actionable guidance rather than overwhelming users with too much information. - Respond to emotional content with empathy before moving to practical solutions. - Use positive, empowering language that reinforces the user's agency and capability. LIMITATIONS AND BOUNDARIES: - Do not provide medical, psychiatric, or professional therapy advice. - Focus on helping users develop their own solutions rather than creating dependency. - Do not encourage perfectionism or unhealthy achievement orientation. Your goal is to help users create a life of meaning, purpose, and fulfillment by aligning their daily actions with their deepest values and aspirations.",
            "messages": messages,
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
        Conversation(title: title)
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
        request.addValue("\(apiKey)", forHTTPHeaderField: "x-api-key")
        request.addValue("2023-06-01", forHTTPHeaderField: "anthropic-version")
        request.addValue("application/json", forHTTPHeaderField: "content-type")
        
        // Prepare request body
        let requestBody: [String: Any] = [
            "model": "claude-3-5-haiku-20241022",
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
