//
//  ChatView.swift
//  Lumina
//
//  Created by Mikael Weiss on 2/24/25.
//

import SwiftUI

struct ChatView: View {
    @State private var viewModel = ChatViewModel(chatService: ClaudeAPIService())
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Messages list
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            if let conversation = viewModel.currentConversation {
                                ForEach(conversation.messages) { message in
                                    MessageBubble(message: message)
                                }
                            }
                            
                            if viewModel.isLoading {
                                TypingIndicator()
                                    .padding(.leading)
                                    .id("typingIndicator")
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top, 10)
                        .padding(.bottom, 8)
                    }
                    .onChange(of: viewModel.currentConversation?.messages.count) { _, _ in
                        if let lastMessage = viewModel.currentConversation?.messages.last {
                            withAnimation {
                                proxy.scrollTo(lastMessage.id, anchor: .bottom)
                            }
                        }
                    }
                    .onChange(of: viewModel.isLoading) { _, _ in
                        if viewModel.isLoading {
                            withAnimation {
                                proxy.scrollTo("typingIndicator", anchor: .bottom)
                            }
                        }
                    }
                }
                .background(Color(UIColor.systemBackground))
                .overlay(
                    Group {
                        if let conversation = viewModel.currentConversation, conversation.messages.isEmpty {
                            Text("How can I help you today?")
                                .font(.largeTitle)
                                .fontDesign(.rounded)
                                .padding()
                        }
                    }
                )
                
                Spacer()
                
                // Input area
                ChatInputView(
                    text: $viewModel.messageText,
                    onSend: sendMessage)
            }
            .onAppear {
                if viewModel.currentConversation == nil && !viewModel.conversations.isEmpty {
                    viewModel.selectConversation(viewModel.conversations[0])
                } else if viewModel.currentConversation == nil {
                    viewModel.createNewConversation()
                }
            }
            .navigationTitle(viewModel.currentConversation?.title ?? "Lumina")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("add", systemImage: "plus") {
                        viewModel.createNewConversation()
                    }
                }
            }
            .alert("Error", isPresented: .constant(viewModel.errorMessage != nil), actions: {
                Button("OK") {
                    viewModel.errorMessage = nil
                }
            }, message: {
                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                }
            })
        }
    }
    
    private func sendMessage() {
        Task {
            await viewModel.sendMessage()
        }
    }
}

struct MessageBubble: View {
    let message: Message
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(message.isUserMessage ? "You" : "Lumina")
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.leading, 4)
            
            HStack {
                if message.isUserMessage {
                    Spacer()
                }
                
                Text(message.content)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(
                        message.isUserMessage ? 
                            Color.clear : 
                            Color(UIColor.systemGray6)
                    )
                    .cornerRadius(18)
                    .overlay(
                        RoundedRectangle(cornerRadius: 18)
                            .stroke(message.isUserMessage ? Color.secondary.opacity(0.5) : Color.clear, lineWidth: 1)
                    )
                
                if !message.isUserMessage {
                    Spacer()
                }
            }
        }
    }
}

struct TypingIndicator: View {
    @State private var animationOffset = 0.0
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "sparkles")
                .foregroundColor(Color.accentColor)
                .font(.system(size: 16))
            
            ForEach(0..<3) { index in
                Circle()
                    .fill(Color.secondary.opacity(0.5))
                    .frame(width: 8, height: 8)
                    .offset(y: animationOffset(for: index))
                    .animation(
                        Animation.easeInOut(duration: 0.6)
                            .repeatForever()
                            .delay(Double(index) * 0.2),
                        value: animationOffset
                    )
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(Color(UIColor.systemGray6))
        .cornerRadius(18)
        .onAppear {
            animationOffset = 1.0
        }
    }
    
    private func animationOffset(for index: Int) -> Double {
        return animationOffset * -5.0
    }
}

struct ChatInputView: View {
    @Binding var text: String
    var onSend: () -> Void
    
    var body: some View {
        ZStack {
            // Text input field with dynamic height
            TextField("Reply to Lumina", text: $text, axis: .vertical)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .submitLabel(.send)
                .foregroundColor(.primary)
                .onSubmit(onSend)
                .background(Color(.systemGray5), in: RoundedRectangle(cornerRadius: 20))
        }
        .frame(minHeight: 40)
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(Color(UIColor.systemBackground))
    }
}

#Preview {
    NavigationStack {
        ChatView()
    }
}
