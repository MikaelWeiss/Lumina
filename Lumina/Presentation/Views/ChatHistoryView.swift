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

    var body: some View {
        NavigationStack {
            List {
                ForEach(conversations) { conversation in
                    NavigationLink(value: conversation) {
                        ConversationRow(conversation: conversation)
                    }
                }
                .onDelete(perform: deleteConversations)
            }
            .navigationTitle("Conversations")
            .navigationDestination(for: Conversation.self) { conversation in
                ChatView(conversation: conversation)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("New Chat", systemImage: "plus") {
                        createNewConversation()
                    }
                }
            }
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
    ChatHistoryView()
        .modelContainer(for: [Conversation.self, Message.self, Provider.self, LLM.self, MessageAttachment.self])
}
