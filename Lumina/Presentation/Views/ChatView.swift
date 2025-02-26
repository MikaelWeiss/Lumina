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
    @State private var isShowingRenameSheet = false
    @State private var newConversationTitle = ""
    
    var body: some View {
        NavigationSplitView {
            // Sidebar with conversation list
            List(viewModel.conversations.sorted(by: { $0.createdAt > $1.createdAt }), selection: Binding(
                get: { viewModel.currentConversation.id },
                set: { newId in
                    if let newId, let conversation = viewModel.conversations.first(where: { $0.id == newId }) {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            viewModel.selectConversation(conversation)
                        }
                    }
                }
            )) { conversation in
                HStack {
                    Image(systemName: "bubble.left.fill")
                        .foregroundStyle(.secondary)
                    Text(conversation.title)
                        .lineLimit(1)
                        .truncationMode(.tail)
                }
                .swipeActions {
                    Button("Delete", systemImage: "trash.fill") { viewModel.didTapDelete(conversation) }
                        .tint(Color.red)
                }
                .transition(.asymmetric(
                    insertion: .scale(scale: 0.8).combined(with: .opacity).animation(.spring(response: 0.4, dampingFraction: 0.7)),
                    removal: .scale(scale: 0.6).combined(with: .opacity).animation(.easeOut(duration: 0.25))
                ))
            }
            .animation(.spring(response: 0.4, dampingFraction: 0.8), value: viewModel.conversations.count)
            .navigationTitle("Conversations")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("add", systemImage: "plus") {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                            viewModel.createNewConversation()
                        }
                    }
                }
            }
            .onAppear {
                viewModel.loadConversations()
            }
            .confirmationDialog("Are you sure you want to delete this conversation?", isPresented: $viewModel.showConfirmDeleteConversation) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        viewModel.deleteSwipedConversation()
                    }
                }
            }
        } detail: {
            // Detail view with chat content
            VStack(spacing: 0) {
                // Messages list
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(viewModel.currentConversation.messages) { message in
                                MessageBubble(message: message)
                                    .id(message.id)
                                    .transition(.asymmetric(
                                        insertion: .scale(scale: 0.9)
                                            .combined(with: .opacity)
                                            .combined(with: .offset(y: 20))
                                            .animation(.spring(response: 0.3, dampingFraction: 0.7)),
                                        removal: .opacity.animation(.easeOut(duration: 0.2))
                                    ))
                            }
                            .animation(.spring(response: 0.4, dampingFraction: 0.8), value: viewModel.currentConversation.messages.count)
                            
                            if viewModel.isLoading {
                                TypingIndicator()
                                    .id("typingIndicator")
                                    .transition(.opacity.combined(with: .scale(scale: 0.9)).animation(.easeInOut(duration: 0.2)))
                            }
                            
                            if viewModel.inturrupted, !viewModel.currentConversation.messages.isEmpty {
                                Text("Lumina was inturrupted")
                                    .font(.subheadline)
                                    .padding()
                                    .transition(.opacity.combined(with: .scale(scale: 0.9)).animation(.easeInOut(duration: 0.2)))
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top, 10)
                        .padding(.bottom, 8)
                        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: viewModel.isLoading)
                        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: viewModel.inturrupted)
                    }
                    .scrollDismissesKeyboard(.interactively)
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
                            VStack(spacing: 16) {
                                Image(systemName: "sparkles")
                                    .font(.system(size: 40))
                                    .foregroundStyle(.secondary)
                                
                                Text("How can I help you today?")
                                    .font(.title)
                                    .fontWeight(.medium)
                                    .fontDesign(.rounded)
                                    .multilineTextAlignment(.center)
                                    .foregroundStyle(.secondary)
                            }
                            .padding(30)
                            .frame(maxWidth: 300)
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
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                            viewModel.createNewConversation()
                        }
                    }
                }
                ToolbarItem(placement: .principal) {
                    Button(viewModel.currentConversation.title) {
                        newConversationTitle = viewModel.currentConversation.title
                        isShowingRenameSheet = true
                    }
                    .tint(Color.primary)
                }
            }
            .sheet(isPresented: $isShowingRenameSheet) {
                VStack(spacing: 20) {
                    Text("Rename Conversation")
                        .font(.headline)
                    
                    TextField("Conversation Title", text: $newConversationTitle)
                        .textFieldStyle(.roundedBorder)
                        .padding(.horizontal)
                    
                    HStack {
                        Button("Cancel") {
                            isShowingRenameSheet = false
                        }
                        .buttonStyle(.bordered)
                        
                        Button("Save") {
                            viewModel.updateConversationTitle(newTitle: newConversationTitle)
                            isShowingRenameSheet = false
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(newConversationTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    }
                }
                .padding()
                .presentationDetents([.height(200)])
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
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: viewModel.currentConversation.id)
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
    @State private var isAnimating = false
    
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
                    .scaleEffect(isAnimating ? 1.0 : 0.9)
                    .opacity(isAnimating ? 1.0 : 0.5)
                
                if !message.isUserMessage {
                    Spacer()
                }
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                isAnimating = true
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
                            .delay(Double(index) * 0.3),
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
    ChatView()
}
