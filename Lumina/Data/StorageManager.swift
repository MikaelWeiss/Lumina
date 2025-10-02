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
            seedDefaultProvidersIfNeeded()
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }

    /// Seeds default providers if no providers exist in the database
    private func seedDefaultProvidersIfNeeded() {
        let context = container.mainContext

        // Check if providers already exist
        let fetchDescriptor = FetchDescriptor<Provider>()
        if let existingProviders = try? context.fetch(fetchDescriptor), !existingProviders.isEmpty {
            return
        }

        // Create default providers
        let defaultProviders = [
            Provider(name: "OpenAI", endpoint: "https://api.openai.com/v1", isCustom: false),
            Provider(name: "Anthropic (Claude)", endpoint: "https://api.anthropic.com/v1", isCustom: false),
            Provider(name: "Google (Gemini)", endpoint: "https://generativelanguage.googleapis.com/v1beta", isCustom: false),
            Provider(name: "Mistral", endpoint: "https://api.mistral.ai/v1", isCustom: false),
            Provider(name: "Cohere", endpoint: "https://api.cohere.ai/v1", isCustom: false),
            Provider(name: "Groq", endpoint: "https://api.groq.com/openai/v1", isCustom: false),
            Provider(name: "Together AI", endpoint: "https://api.together.xyz/v1", isCustom: false),
            Provider(name: "Perplexity", endpoint: "https://api.perplexity.ai", isCustom: false),
            Provider(name: "OpenRouter", endpoint: "https://openrouter.ai/api/v1", isCustom: false),
            Provider(name: "Ollama (Local)", endpoint: "http://localhost:11434/v1", isCustom: false),
            Provider(name: "LM Studio (Local)", endpoint: "http://localhost:1234/v1", isCustom: false)
        ]

        for provider in defaultProviders {
            context.insert(provider)
        }

        try? context.save()
    }
}