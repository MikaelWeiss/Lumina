//
//  ProvidersView.swift
//  Lumina
//
//  Created by Mikael Weiss on 10/2/25.
//

import SwiftUI
import SwiftData

struct ProvidersView: View {
    @Query private var providers: [Provider]
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
        }
        .navigationTitle("Providers")
        .toolbar {
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
}

struct ProviderRowView: View {
    let provider: Provider

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(provider.name)
                        .font(.headline)

                    if provider.isCustom {
                        Text("Custom")
                            .font(.caption2)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(.blue.opacity(0.2))
                            .foregroundStyle(.blue)
                            .clipShape(Capsule())
                    }
                }

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
