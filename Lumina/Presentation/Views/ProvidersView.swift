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

    var body: some View {
        List {
            ForEach(providers) { provider in
                NavigationLink(destination: Text("Provider Details")) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(provider.name)
                            .font(.headline)
                        Text(provider.endpoint)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .navigationTitle("Providers")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Add", systemImage: "plus") {
                    // Add provider action
                }
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
