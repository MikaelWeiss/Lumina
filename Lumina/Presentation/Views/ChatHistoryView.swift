//
//  ChatHistoryView.swift
//  Lumina
//
//  Created by Mikael Weiss on 9/27/25.
//

import SwiftUI
import SwiftData

struct ChatHistoryView: View {
    @Query(sort: \Conversation.updatedAt, order: .reverse) private var conversations: [Conversation]
    @Environment(\.modelContext) private var modelContext
    @Binding var selectedConversation: Conversation?
    @State private var showingSettings = false

    var body: some View {
        List(selection: $selectedConversation) {
            ForEach(conversations) { conversation in
                NavigationLink(value: conversation) {
                    ConversationRow(conversation: conversation)
                }
            }
            .onDelete(perform: deleteConversations)
        }
        .navigationTitle("Conversations")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Settings", systemImage: "gear") {
                    showingSettings = true
                }
            }
        }
        .overlay(alignment: .bottomTrailing) {
            Button {
                createNewConversation()
            } label: {
                Image(systemName: "plus")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                    .frame(width: 56, height: 56)
                    .background(Circle().fill(.blue))
                    .shadow(radius: 4, y: 2)
            }
            .padding()
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView()
        }
    }

    private func deleteConversations(offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(conversations[index])
        }
    }

    private func createNewConversation() {
        let newConversation = Conversation()
        modelContext.insert(newConversation)
        selectedConversation = newConversation
    }
}

struct ConversationRow: View {
    let conversation: Conversation

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(conversation.title)
                    .font(.headline)
                    .lineLimit(1)
                Spacer()
                Text(conversation.updatedAt, format: .relative(presentation: .named))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            if let lastMessage = conversation.messages.last {
                Text(lastMessage.text)
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            } else {
                Text("No messages")
                    .font(.body)
                    .foregroundStyle(.tertiary)
                    .italic()
            }
        }
        .padding(.vertical, 2)
    }
}

#Preview {
    ChatHistoryView(selectedConversation: .constant(nil))
        .modelContainer(for: [Conversation.self, Message.self, Provider.self, LLM.self, MessageAttachment.self])
}
