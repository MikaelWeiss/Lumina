//
//  ChatView.swift
//  Lumina
//
//  Created by Mikael Weiss on 2/24/25.
//

import SwiftUI

struct Message: Identifiable {
    let id = UUID().uuidString
    let content: String
    let isUser: Bool
    let timestamp: Date
}

struct ChatView: View {
    @State private var messages: [Message] = []
    @State private var newMessage: String = ""
    @State private var isTyping: Bool = false
    @FocusState private var isInputFocused: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            // Chat header
            ChatHeader()
            
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
            .background(Color(.systemGroupedBackground))
            
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
            Message(content: "Hello! How can I help you today?", isUser: false, timestamp: Date().addingTimeInterval(-3600)),
            Message(content: "I'm working on a SwiftUI project and need some help with animations.", isUser: true, timestamp: Date().addingTimeInterval(-3500)),
            Message(content: "I'd be happy to help with SwiftUI animations! What specific aspect are you struggling with?", isUser: false, timestamp: Date().addingTimeInterval(-3400))
        ]
        
        messages.append(contentsOf: sampleMessages)
    }
}

struct ChatHeader: View {
    var body: some View {
        HStack {
            Text("AI Assistant")
                .font(.headline)
                .foregroundColor(.primary)
            
            Spacer()
            
            Button(action: {
                // Clear chat action would go here
            }) {
                Image(systemName: "trash")
                    .foregroundColor(.gray)
            }
            .buttonStyle(BorderlessButtonStyle())
        }
        .padding()
        .background(
            Color(.systemBackground)
                .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
        )
    }
}

struct MessageBubble: View {
    let message: Message
    
    var body: some View {
        HStack {
            if message.isUser {
                Spacer()
            }
            
            VStack(alignment: message.isUser ? .trailing : .leading, spacing: 2) {
                Text(message.content)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(message.isUser ? Color.blue : Color(.systemGray5))
                    .foregroundColor(message.isUser ? .white : .primary)
                    .cornerRadius(18)
                
                Text(formatTimestamp(message.timestamp))
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 4)
            }
            
            if !message.isUser {
                Spacer()
            }
        }
    }
    
    private func formatTimestamp(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

struct TypingIndicator: View {
    @State private var animationOffset = 0.0
    
    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<3) { index in
                Circle()
                    .fill(Color.gray.opacity(0.5))
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
        .background(Color(.systemGray5))
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
        HStack(spacing: 12) {
            // Text input field
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(.systemGray6))
                
                TextField("Message", text: $text, axis: .vertical)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .focused($isInputFocused)
                    .lineLimit(1...5)
                    .submitLabel(.send)
                    .onSubmit {
                        onSend()
                    }
            }
            .frame(minHeight: 40)
            
            // Send button
            Button(action: onSend) {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.system(size: 30))
                    .foregroundColor(text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? .gray : .blue)
            }
            .disabled(text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(Color(.systemBackground))
    }
}

#Preview {
    ChatView()
}
