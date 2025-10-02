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

        // Create default providers (sorted by popularity)
        let defaultProviders = [
            Provider(name: "OpenAI", endpoint: "https://api.openai.com/v1", isCustom: false, sortOrder: 1),
            Provider(name: "Anthropic (Claude)", endpoint: "https://api.anthropic.com/v1", isCustom: false, sortOrder: 2),
            Provider(name: "Google (Gemini)", endpoint: "https://generativelanguage.googleapis.com/v1beta", isCustom: false, sortOrder: 3),
            Provider(name: "Groq", endpoint: "https://api.groq.com/openai/v1", isCustom: false, sortOrder: 4),
            Provider(name: "OpenRouter", endpoint: "https://openrouter.ai/api/v1", isCustom: false, sortOrder: 5),
            Provider(name: "Perplexity", endpoint: "https://api.perplexity.ai", isCustom: false, sortOrder: 6),
            Provider(name: "Together AI", endpoint: "https://api.together.xyz/v1", isCustom: false, sortOrder: 7),
            Provider(name: "Mistral", endpoint: "https://api.mistral.ai/v1", isCustom: false, sortOrder: 8),
            Provider(name: "Cohere", endpoint: "https://api.cohere.ai/v1", isCustom: false, sortOrder: 9)
        ]

        for provider in defaultProviders {
            context.insert(provider)
        }

        try? context.save()
    }
}
