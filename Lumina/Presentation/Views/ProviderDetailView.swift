//
//  ProviderDetailView.swift
//  Lumina
//
//  Created by Mikael Weiss on 10/2/25.
//

import SwiftUI
import SwiftData

struct ProviderDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var provider: Provider

    @State private var showEditSheet = false
    @State private var apiKey = ""
    @State private var showAPIKey = false
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var isLoadingModels = false

    var body: some View {
        Form {
            Section {
                LabeledContent("Name", value: provider.name)
                LabeledContent("Endpoint", value: provider.endpoint)

                if let apiKeyURL = provider.apiKeyURL {
                    Link(destination: URL(string: apiKeyURL)!) {
                        HStack {
                            Text("Get API Key")
                            Spacer()
                            Image(systemName: "arrow.up.forward.square")
                                .imageScale(.small)
                        }
                    }
                }
            } header: {
                Text("Provider Information")
            }

            Section {
                HStack {
                    if showAPIKey {
                        TextField("API Key", text: $apiKey)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                            .disabled(true)
                    } else {
                        SecureField("API Key", text: $apiKey)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                    }

                    Button {
                        showAPIKey.toggle()
                    } label: {
                        Image(systemName: showAPIKey ? "eye.slash.fill" : "eye.fill")
                            .foregroundStyle(.secondary)
                    }
                }

                Button("Save API Key") {
                    saveAPIKey()
                }
                .disabled(apiKey.isEmpty)

                if provider.hasAPIKey {
                    Button("Remove API Key", role: .destructive) {
                        removeAPIKey()
                    }
                }
            } header: {
                Text("API Key")
            } footer: {
                Text("Your API key is stored securely in the iOS Keychain")
            }

            Section {
                Button("Edit Provider Details") {
                    showEditSheet = true
                }
            }

            Section {
                if isLoadingModels {
                    HStack {
                        Spacer()
                        ProgressView()
                        Spacer()
                    }
                } else if provider.availableLLMs.isEmpty {
                    Text("No models available")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(provider.availableLLMs) { llm in
                        Toggle(llm.name, isOn: Binding(
                            get: { llm.isEnabledForChat },
                            set: { llm.isEnabledForChat = $0 }
                        ))
                    }
                }
            } header: {
                Text("Available Models")
            } footer: {
                if !isLoadingModels && !provider.availableLLMs.isEmpty {
                    Text("Enable models to use them in chat")
                }
            }
        }
        .navigationTitle(provider.name)
        .navigationBarTitleDisplayMode(.inline)
        .alert("Error", isPresented: $showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
        .sheet(isPresented: $showEditSheet) {
            AddEditProviderSheet(provider: provider)
        }
        .onAppear {
            loadAPIKey()
            fetchAvailableModels()
        }
    }

    private func loadAPIKey() {
        do {
            if let key = try provider.getAPIKey() {
                apiKey = key
            }
        } catch {
            errorMessage = "Failed to load API key: \(error.localizedDescription)"
            showError = true
        }
    }

    private func saveAPIKey() {
        do {
            try provider.saveAPIKey(apiKey)
            fetchAvailableModels()
        } catch {
            errorMessage = "Failed to save API key: \(error.localizedDescription)"
            showError = true
        }
    }

    private func removeAPIKey() {
        do {
            try provider.deleteAPIKey()
            apiKey = ""

            // Remove all LLM objects for this provider
            for llm in provider.availableLLMs {
                modelContext.delete(llm)
            }
            provider.availableLLMs.removeAll()
        } catch {
            errorMessage = "Failed to remove API key: \(error.localizedDescription)"
            showError = true
        }
    }

    private func fetchAvailableModels() {
        guard provider.hasAPIKey else {
            return
        }

        isLoadingModels = true

        Task {
            do {
                let modelNames = try await ModelService.fetchModels(for: provider)
                await MainActor.run {
                    // Create or update LLM objects
                    for modelName in modelNames {
                        // Check if this model already exists for this provider
                        let existingModel = provider.availableLLMs.first { $0.name == modelName }

                        if existingModel == nil {
                            // Create new LLM object
                            let newLLM = LLM(name: modelName, isEnabledForChat: false)
                            newLLM.provider = provider
                            provider.availableLLMs.append(newLLM)
                            modelContext.insert(newLLM)
                        }
                    }

                    // Remove models that no longer exist
                    let currentModelNames = Set(modelNames)
                    provider.availableLLMs.removeAll { llm in
                        if !currentModelNames.contains(llm.name) {
                            modelContext.delete(llm)
                            return true
                        }
                        return false
                    }

                    self.isLoadingModels = false
                }
            } catch {
                await MainActor.run {
                    self.isLoadingModels = false
                    self.errorMessage = "Failed to fetch models: \(error.localizedDescription)"
                    self.showError = true
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        ProviderDetailView(provider: Provider(name: "OpenAI", endpoint: "https://api.openai.com/v1"))
            .modelContainer(for: [Provider.self])
    }
}
