//
//  ChatView.swift
//  Lumina
//
//  Created by Mikael Weiss on 2/24/25.
//

import SwiftUI

struct ChatView: View {
    @State private var messages: [ChatView.Message] = []
    @State private var newMessage: String = ""
    @State private var isTyping: Bool = false
    @FocusState private var isInputFocused: Bool
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        VStack(spacing: 0) {
            // Messages list
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(messages) { message in
                            MessageBubble(message: message)
                        }
                        
                        if isTyping {
                            TypingIndicator()
                                .padding(.leading)
                                .id("typingIndicator")
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 10)
                    .padding(.bottom, 8)
                }
                .onChange(of: messages.count) { _, _ in
                    withAnimation {
                        proxy.scrollTo(messages.last?.id ?? "typingIndicator", anchor: .bottom)
                    }
                }
                .onChange(of: isTyping) { _, _ in
                    withAnimation {
                        proxy.scrollTo("typingIndicator", anchor: .bottom)
                    }
                }
            }
            .background(Color(UIColor.systemBackground))
            
            Spacer()
            
            // Input area
            ChatInputView(
                text: $newMessage,
                isInputFocused: _isInputFocused,
                onSend: sendMessage)
        }
        .onAppear {
            // Add some sample messages for preview
            if messages.isEmpty {
                addSampleMessages()
            }
        }
        .navigationTitle("Lumina")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("add", systemImage: "plus") {
                    
                }
            }
        }
    }
    
    private func sendMessage() {
        guard !newMessage.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        let userMessage = Message(content: newMessage, isUser: true, timestamp: Date())
        messages.append(userMessage)
        newMessage = ""
        
        // Simulate AI response
        isTyping = true
        
        // Simulate delay for AI response
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            let aiResponse = Message(
                content: "This is a simulated response from the AI assistant.",
                isUser: false,
                timestamp: Date()
            )
            messages.append(aiResponse)
            isTyping = false
        }
    }
    
    private func addSampleMessages() {
        let sampleMessages: [Message] = [
            Message(content: "Hello there!", isUser: true, timestamp: Date().addingTimeInterval(-3600)),
            Message(content: "Hello! It's nice to meet you. How can I help you today?", isUser: false, timestamp: Date().addingTimeInterval(-3500)),
        ]
        
        messages.append(contentsOf: sampleMessages)
    }
    
    struct Message: Identifiable {
        let id = UUID().uuidString
        let content: String
        let isUser: Bool
        let timestamp: Date
    }
}

struct MessageBubble: View {
    let message: ChatView.Message
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            if !message.isUser {
                // Only show the name for AI messages
                Text("Lumina")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.leading, 4)
            } else {
                Text("Mikael")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.leading, 4)
            }
            
            HStack {
                if message.isUser {
                    Spacer()
                }
                
                Text(message.content)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(
                        message.isUser ? 
                            Color.clear : 
                            Color(UIColor.systemGray6)
                    )
                    .cornerRadius(18)
                    .overlay(
                        RoundedRectangle(cornerRadius: 18)
                            .stroke(message.isUser ? Color.secondary.opacity(0.5) : Color.clear, lineWidth: 1)
                    )
                
                if !message.isUser {
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
    @FocusState var isInputFocused: Bool
    var onSend: () -> Void
    
    var body: some View {
        ZStack {
            // Background for the text field
            
            
            // Text input field with dynamic height
            TextField("Reply to Lumina", text: $text, axis: .vertical)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .focused($isInputFocused)
                .submitLabel(.send)
                .foregroundColor(.white)
                .onSubmit {
                    onSend()
                }
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
