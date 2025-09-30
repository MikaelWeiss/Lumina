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
    }
}

#Preview {
    MainView()
        .modelContainer(for: [Conversation.self, Message.self, Provider.self, LLM.self, MessageAttachment.self])
}