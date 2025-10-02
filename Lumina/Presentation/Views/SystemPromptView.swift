//
//  SystemPromptView.swift
//  Lumina
//
//  Created by Mikael Weiss on 10/2/25.
//

import SwiftUI

struct SystemPromptView: View {
    @State private var systemPrompt = ""

    var body: some View {
        Form {
            Section {
                TextEditor(text: $systemPrompt)
                    .frame(minHeight: 200)
            } header: {
                Text("System Prompt")
            } footer: {
                Text("This prompt will be included at the beginning of every conversation.")
            }
        }
        .navigationTitle("System Prompt")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        SystemPromptView()
    }
}
