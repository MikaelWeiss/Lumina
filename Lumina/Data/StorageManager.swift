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

        // Create default providers (OpenAI-compatible endpoints only)
        let defaultProviders = [
            Provider(name: "OpenAI", endpoint: "https://api.openai.com/v1", apiKeyURL: "https://platform.openai.com/api-keys", sortOrder: 1),
            Provider(name: "Anthropic", endpoint: "https://api.anthropic.com/v1", apiKeyURL: "https://console.anthropic.com/", sortOrder: 2),
            Provider(name: "Groq", endpoint: "https://api.groq.com/openai/v1", apiKeyURL: "https://console.groq.com/keys", sortOrder: 3),
            Provider(name: "Google AI", endpoint: "https://generativelanguage.googleapis.com/v1beta/openai", apiKeyURL: "https://aistudio.google.com/app/apikey", sortOrder: 4),
            Provider(name: "OpenRouter", endpoint: "https://openrouter.ai/api/v1", apiKeyURL: "https://openrouter.ai/settings/keys", sortOrder: 5),
            Provider(name: "DeepInfra", endpoint: "https://api.deepinfra.com/v1/openai", apiKeyURL: "https://deepinfra.com/", sortOrder: 6),
            Provider(name: "Baseten", endpoint: "https://inference.baseten.co/v1", apiKeyURL: "https://docs.baseten.co/observability/api-keys", sortOrder: 7),
            Provider(name: "Inception Labs", endpoint: "https://api.inceptionlabs.ai/v1", apiKeyURL: "https://api.inceptionlabs.ai/", sortOrder: 8),
            Provider(name: "Kimi", endpoint: "https://api.moonshot.cn/v1", apiKeyURL: "https://platform.moonshot.ai/", sortOrder: 9),
            Provider(name: "Deepseek", endpoint: "https://api.deepseek.com/v1", apiKeyURL: "https://platform.deepseek.com/", sortOrder: 10),
            Provider(name: "Alibaba", endpoint: "https://dashscope.aliyuncs.com/compatible-mode/v1", apiKeyURL: "https://www.alibabacloud.com/help/en/model-studio/first-api-call-to-qwen", sortOrder: 11),
            Provider(name: "Perplexity", endpoint: "https://api.perplexity.ai", apiKeyURL: "https://www.perplexity.ai/settings/api", sortOrder: 12),
            Provider(name: "Together AI", endpoint: "https://api.together.xyz/v1", apiKeyURL: "https://api.together.xyz/settings/api-keys", sortOrder: 13),
            Provider(name: "Mistral", endpoint: "https://api.mistral.ai/v1", apiKeyURL: "https://console.mistral.ai/api-keys/", sortOrder: 14),
            Provider(name: "Cohere", endpoint: "https://api.cohere.ai/compatibility/v1", apiKeyURL: "https://dashboard.cohere.com/api-keys", sortOrder: 15)
        ]

        for provider in defaultProviders {
            context.insert(provider)
        }

        try? context.save()
    }
}
