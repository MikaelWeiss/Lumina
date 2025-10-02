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
                    newProvider = Provider(name: customName, endpoint: customEndpoint, isCustom: true)
                } else {
                    guard let type = selectedProviderType else { return }
                    newProvider = Provider(name: type.displayName, endpoint: type.endpoint, isCustom: false)
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
}

// MARK: - Default Provider Types

enum DefaultProviderType: String, CaseIterable, Identifiable {
    case openai
    case anthropic
    case google
    case mistral
    case cohere
    case groq
    case together
    case perplexity
    case openrouter
    case ollama
    case lmstudio

    var id: String { self.rawValue }

    var displayName: String {
        switch self {
        case .openai: return "OpenAI"
        case .anthropic: return "Anthropic (Claude)"
        case .google: return "Google (Gemini)"
        case .mistral: return "Mistral"
        case .cohere: return "Cohere"
        case .groq: return "Groq"
        case .together: return "Together AI"
        case .perplexity: return "Perplexity"
        case .openrouter: return "OpenRouter"
        case .ollama: return "Ollama (Local)"
        case .lmstudio: return "LM Studio (Local)"
        }
    }

    var endpoint: String {
        switch self {
        case .openai: return "https://api.openai.com/v1"
        case .anthropic: return "https://api.anthropic.com/v1"
        case .google: return "https://generativelanguage.googleapis.com/v1beta"
        case .mistral: return "https://api.mistral.ai/v1"
        case .cohere: return "https://api.cohere.ai/v1"
        case .groq: return "https://api.groq.com/openai/v1"
        case .together: return "https://api.together.xyz/v1"
        case .perplexity: return "https://api.perplexity.ai"
        case .openrouter: return "https://openrouter.ai/api/v1"
        case .ollama: return "http://localhost:11434/v1"
        case .lmstudio: return "http://localhost:1234/v1"
        }
    }
}

#Preview {
    AddEditProviderSheet()
        .modelContainer(for: [Provider.self])
}
