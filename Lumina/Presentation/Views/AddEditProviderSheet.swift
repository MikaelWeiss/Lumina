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

    @State private var name = ""
    @State private var endpoint = ""
    @State private var apiKey = ""
    @State private var apiKeyURL = ""
    @State private var showError = false
    @State private var errorMessage = ""

    let provider: Provider?

    init(provider: Provider? = nil) {
        self.provider = provider
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Provider Details") {
                    TextField("Name", text: $name)
                    TextField("Endpoint URL", text: $endpoint)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .keyboardType(.URL)
                }

                Section {
                    SecureField("API Key", text: $apiKey)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()

                    if let url = URL(string: apiKeyURL), !apiKeyURL.isEmpty {
                        Link(destination: url) {
                            HStack {
                                Text("Get API Key")
                                Spacer()
                                Image(systemName: "arrow.up.forward.square")
                                    .imageScale(.small)
                            }
                        }
                    }
                } header: {
                    Text("API Key")
                } footer: {
                    Text("Your API key is stored securely in the iOS Keychain")
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
        return !name.isEmpty && !endpoint.isEmpty && !apiKey.isEmpty
    }

    private func loadExistingProvider() {
        guard let provider = provider else { return }

        name = provider.name
        endpoint = provider.endpoint
        apiKeyURL = provider.apiKeyURL ?? ""

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
                existingProvider.name = name
                existingProvider.endpoint = endpoint
                existingProvider.apiKeyURL = apiKeyURL.isEmpty ? nil : apiKeyURL
                try existingProvider.saveAPIKey(apiKey)
            } else {
                // Create new provider
                let newProvider = Provider(
                    name: name,
                    endpoint: endpoint,
                    apiKeyURL: apiKeyURL.isEmpty ? nil : apiKeyURL,
                    sortOrder: getNextSortOrder()
                )

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

#Preview {
    AddEditProviderSheet()
        .modelContainer(for: [Provider.self])
}
