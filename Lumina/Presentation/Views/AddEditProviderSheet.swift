//
//  AddEditProviderSheet.swift
//  Lumina
//
//  Created by Mikael Weiss on 10/2/25.
//

import SwiftUI
import SwiftData

struct AddEditProviderSheet: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var selectedProviderType: DefaultProviderType?
    @State private var customName = ""
    @State private var customEndpoint = ""
    @State private var apiKey = ""
    @State private var isCustom = false
    @State private var showError = false
    @State private var errorMessage = ""

    let provider: Provider?

    init(provider: Provider? = nil) {
        self.provider = provider
    }

    var body: some View {
        NavigationStack {
            Form {
                if provider == nil {
                    Section {
                        Picker("Provider Type", selection: $isCustom) {
                            Text("Default Provider").tag(false)
                            Text("Custom Provider").tag(true)
                        }
                        .pickerStyle(.segmented)
                    }
                }

                if !isCustom && provider == nil {
                    Section("Select Provider") {
                        Picker("Provider", selection: $selectedProviderType) {
                            Text("Select...").tag(nil as DefaultProviderType?)
                            ForEach(DefaultProviderType.allCases) { type in
                                Text(type.displayName).tag(type as DefaultProviderType?)
                            }
                        }

                        if let selected = selectedProviderType {
                            Text(selected.endpoint)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                } else {
                    Section("Provider Details") {
                        TextField("Name", text: $customName)
                        TextField("Endpoint URL", text: $customEndpoint)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                            .keyboardType(.URL)
                    }
                }

                Section("API Key") {
                    SecureField("API Key", text: $apiKey)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                }
            }
            .navigationTitle(provider == nil ? "Add Provider" : "Edit Provider")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveProvider()
                    }
                    .disabled(!canSave)
                }
            }
            .alert("Error", isPresented: $showError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
            .onAppear {
                loadExistingProvider()
            }
        }
    }

    private var canSave: Bool {
        if isCustom || provider?.isCustom == true {
            return !customName.isEmpty && !customEndpoint.isEmpty && !apiKey.isEmpty
        } else {
            return selectedProviderType != nil && !apiKey.isEmpty
        }
    }

    private func loadExistingProvider() {
        guard let provider = provider else { return }

        isCustom = provider.isCustom
        customName = provider.name
        customEndpoint = provider.endpoint

        // Try to load existing API key
        do {
            if let existingKey = try provider.getAPIKey() {
                apiKey = existingKey
            }
        } catch {
            // Ignore errors when loading API key
        }
    }

    private func saveProvider() {
        do {
            if let existingProvider = provider {
                // Update existing provider
                existingProvider.name = customName
                existingProvider.endpoint = customEndpoint
                try existingProvider.saveAPIKey(apiKey)
            } else {
                // Create new provider
                let newProvider: Provider
                if isCustom {
                    newProvider = Provider(name: customName, endpoint: customEndpoint, isCustom: true, sortOrder: getNextSortOrder())
                } else {
                    guard let type = selectedProviderType else { return }
                    newProvider = Provider(name: type.displayName, endpoint: type.endpoint, isCustom: false, sortOrder: getNextSortOrder())
                }

                modelContext.insert(newProvider)
                try modelContext.save()
                try newProvider.saveAPIKey(apiKey)
            }

            dismiss()
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
    }

    private func getNextSortOrder() -> Int {
        let descriptor = FetchDescriptor<Provider>(sortBy: [SortDescriptor(\Provider.sortOrder, order: .reverse)])
        if let providers = try? modelContext.fetch(descriptor),
           let maxSortOrder = providers.first?.sortOrder {
            return maxSortOrder + 1
        }
        return 1
    }
}

// MARK: - Default Provider Types

enum DefaultProviderType: String, CaseIterable, Identifiable {
    case openai
    case anthropic
    case groq
    case google
    case zai
    case openrouter
    case deepinfra
    case baseten
    case inceptionLabs
    case kimi
    case deepseek
    case alibaba
    case perplexity
    case together
    case mistral
    case cohere

    var id: String { self.rawValue }

    var displayName: String {
        switch self {
        case .openai: return "OpenAI"
        case .anthropic: return "Anthropic"
        case .groq: return "Groq"
        case .google: return "Google AI"
        case .zai: return "z.ai"
        case .openrouter: return "OpenRouter"
        case .deepinfra: return "DeepInfra"
        case .baseten: return "Baseten"
        case .inceptionLabs: return "Inception Labs"
        case .kimi: return "Kimi"
        case .deepseek: return "Deepseek"
        case .alibaba: return "Alibaba"
        case .perplexity: return "Perplexity"
        case .together: return "Together AI"
        case .mistral: return "Mistral"
        case .cohere: return "Cohere"
        }
    }

    var endpoint: String {
        switch self {
        case .openai: return "https://api.openai.com/v1"
        case .anthropic: return "https://api.anthropic.com/v1"
        case .groq: return "https://api.groq.com/openai/v1"
        case .google: return "https://generativelanguage.googleapis.com/v1beta"
        case .zai: return "https://api.z.ai/v1"
        case .openrouter: return "https://openrouter.ai/api/v1"
        case .deepinfra: return "https://api.deepinfra.com/v1/openai"
        case .baseten: return "https://model.baseten.co/v1"
        case .inceptionLabs: return "https://api.inceptionlabs.ai/v1"
        case .kimi: return "https://api.moonshot.cn/v1"
        case .deepseek: return "https://api.deepseek.com/v1"
        case .alibaba: return "https://dashscope.aliyuncs.com/compatible-mode/v1"
        case .perplexity: return "https://api.perplexity.ai"
        case .together: return "https://api.together.xyz/v1"
        case .mistral: return "https://api.mistral.ai/v1"
        case .cohere: return "https://api.cohere.ai/v1"
        }
    }
}

#Preview {
    AddEditProviderSheet()
        .modelContainer(for: [Provider.self])
}
