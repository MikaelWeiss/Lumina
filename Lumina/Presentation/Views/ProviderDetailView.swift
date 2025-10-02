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
    @State private var fetchedModels = [String]()
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
                } else if fetchedModels.isEmpty {
                    Text("No models available")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(fetchedModels, id: \.self) { modelName in
                        Text(modelName)
                    }
                }
            } header: {
                Text("Available Models")
            } footer: {
                if !isLoadingModels && !fetchedModels.isEmpty {
                    Text("Models fetched from provider endpoint")
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
            fetchedModels = []
        } catch {
            errorMessage = "Failed to remove API key: \(error.localizedDescription)"
            showError = true
        }
    }

    private func fetchAvailableModels() {
        guard provider.hasAPIKey else {
            fetchedModels = []
            return
        }

        isLoadingModels = true

        Task {
            do {
                let models = try await ModelService.fetchModels(for: provider)
                await MainActor.run {
                    self.fetchedModels = models
                    self.isLoadingModels = false
                }
            } catch {
                await MainActor.run {
                    self.fetchedModels = []
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
