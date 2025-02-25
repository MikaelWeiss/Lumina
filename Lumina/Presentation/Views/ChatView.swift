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
                            ForEach(viewModel.currentConversation.messages) { message in
                                MessageBubble(message: message)
                                    .id(message.id)
                            }
                            
                            if viewModel.isLoading {
                                TypingIndicator()
                                    .padding(.leading)
                                    .id("typingIndicator")
                            }
                            
                            if viewModel.inturrupted, !viewModel.currentConversation.messages.isEmpty {
                                Text("Lumina was inturrupted")
                                    .font(.subheadline)
                                    .padding()
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top, 10)
                        .padding(.bottom, 8)
                    }
                    .onAppear { scrollToBottom(proxy: proxy) }
                    .onChange(of: viewModel.currentConversation.messages.count) { _, _ in
                        scrollToBottom(proxy: proxy)
                    }
                    .onChange(of: viewModel.currentConversation.id) { _, _ in
                        scrollToBottom(proxy: proxy)
                    }
                    .onChange(of: viewModel.isLoading) { _, _ in
                        if viewModel.isLoading {
                            withAnimation {
                                proxy.scrollTo("typingIndicator", anchor: .bottom)
                            }
                        }
                    }
                }
                .overlay(
                    Group {
                        if viewModel.currentConversation.messages.isEmpty {
                            Text("How can I help you today?")
                                .font(.largeTitle)
                                .fontDesign(.rounded)
                                .padding()
                        }
                    }
                )
                
                Spacer()
                
                // Input area
                ChatInputView(messageText: $viewModel.messageText,
                              messageLoading: viewModel.isLoading,
                              onSend: sendMessage)
            }
            .navigationTitle(viewModel.currentConversation.title)
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
            await viewModel.didTapSendOrStop()
        }
    }
    
    private func scrollToBottom(proxy: ScrollViewProxy) {
        if let lastMessage = viewModel.currentConversation.messages.last {
            withAnimation {
                proxy.scrollTo(lastMessage.id, anchor: .bottom)
            }
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

#Preview {
    NavigationStack {
        ChatView()
    }
}
