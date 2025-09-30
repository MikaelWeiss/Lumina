//
//  MainView.swift
//  Lumina
//
//  Created by Mikael Weiss on 9/27/25.
//

import SwiftUI
import SwiftData

struct MainView: View {
    @State private var selectedConversation: Conversation?
    @Environment(\.modelContext) private var modelContext
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        NavigationSplitView {
            ChatHistoryView(selectedConversation: $selectedConversation)
        } detail: {
            if let conversation = selectedConversation {
                ChatView(conversation: conversation)
            } else {
                ContentUnavailableView(
                    "No Conversation Selected",
                    systemImage: "bubble.left.and.bubble.right",
                    description: Text("Select a conversation from the sidebar or create a new one to start chatting.")
                )
            }
        }
        .onAppear {
            startNewConversation()
        }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .background {
                cleanupEmptyConversations()
            }
        }
    }

    private func cleanupEmptyConversations() {
        let descriptor = FetchDescriptor<Conversation>()
        guard let allConversations = try? modelContext.fetch(descriptor) else { return }

        for conversation in allConversations {
            if conversation.messages.isEmpty && conversation.title == "New Conversation" {
                modelContext.delete(conversation)
            }
        }
    }
    
    private func startNewConversation() {
        let newConversation = Conversation()
        modelContext.insert(newConversation)
        selectedConversation = newConversation
    }
}

#Preview {
    MainView()
        .modelContainer(for: [Conversation.self, Message.self, Provider.self, LLM.self, MessageAttachment.self])
}
