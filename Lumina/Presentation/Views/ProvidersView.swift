//
//  ProvidersView.swift
//  Lumina
//
//  Created by Mikael Weiss on 10/2/25.
//

import SwiftUI
import SwiftData

struct ProvidersView: View {
    @Query(sort: \Provider.sortOrder) private var providers: [Provider]
    @Environment(\.modelContext) private var modelContext

    @State private var showAddSheet = false

    var body: some View {
        List {
            ForEach(providers) { provider in
                NavigationLink(destination: ProviderDetailView(provider: provider)) {
                    ProviderRowView(provider: provider)
                }
            }
            .onDelete(perform: deleteProviders)
            .onMove(perform: moveProviders)
        }
        .navigationTitle("Providers")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                EditButton()
            }

            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Add", systemImage: "plus") {
                    showAddSheet = true
                }
            }
        }
        .sheet(isPresented: $showAddSheet) {
            AddEditProviderSheet()
        }
    }

    private func deleteProviders(at offsets: IndexSet) {
        for index in offsets {
            let provider = providers[index]
            // Delete API key from Keychain before deleting provider
            try? provider.deleteAPIKey()
            modelContext.delete(provider)
        }
    }

    private func moveProviders(from source: IndexSet, to destination: Int) {
        var reorderedProviders = providers
        reorderedProviders.move(fromOffsets: source, toOffset: destination)

        // Update sortOrder for all providers
        for (index, provider) in reorderedProviders.enumerated() {
            provider.sortOrder = index + 1
        }
    }
}

struct ProviderRowView: View {
    let provider: Provider

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(provider.name)
                    .font(.headline)

                Text(provider.endpoint)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }

            Spacer()

            if provider.hasAPIKey {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(.green)
                    .imageScale(.medium)
            } else {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundStyle(.orange)
                    .imageScale(.medium)
            }
        }
    }
}

#Preview {
    NavigationStack {
        ProvidersView()
            .modelContainer(for: [Provider.self])
    }
}
