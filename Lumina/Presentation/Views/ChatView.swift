//
//  ChatView.swift
//  Lumina
//
//  Created by Mikael Weiss on 9/27/25.
//

import SwiftUI
import SwiftData

struct ChatView: View {
    let conversation: Conversation
    @Environment(\.modelContext) private var modelContext
    @State private var messageText = ""
    @State private var isTyping = false

    var body: some View {
        VStack(spacing: 0) {
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 12) {
                        ForEach(conversation.messages) { message in
                            MessageBubble(message: message)
                                .id(message.id)
                        }

                        if isTyping {
                            TypingIndicator()
                        }
                    }
                    .padding()
                }
                .onChange(of: conversation.messages.count) { _, _ in
                    if let lastMessage = conversation.messages.last {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            proxy.scrollTo(lastMessage.id, anchor: .bottom)
                        }
                    }
                }
            }

            MessageInputView(
                messageText: $messageText,
                onSend: sendMessage
            )
        }
        .navigationTitle(conversation.title)
        .navigationBarTitleDisplayMode(.inline)
    }

    private func sendMessage() {
        guard !messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }

        let userMessage = Message(text: messageText, role: .person)
        userMessage.conversation = conversation
        conversation.messages.append(userMessage)
        conversation.updatedAt = Date()

        let messageToSend = messageText
        messageText = ""

        modelContext.insert(userMessage)

        // Simulate AI response
        simulateAIResponse(to: messageToSend)
    }

    private func simulateAIResponse(to userMessage: String) {
        isTyping = true

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            isTyping = false

            let aiResponse = Message(text: "This is a simulated response to: \"\(userMessage)\"", role: .agent)
            aiResponse.conversation = conversation
            conversation.messages.append(aiResponse)
            conversation.updatedAt = Date()

            modelContext.insert(aiResponse)
        }
    }
}

struct MessageBubble: View {
    let message: Message

    var body: some View {
        HStack {
            if message.role == .person {
                Spacer(minLength: 50)
            }

            VStack(alignment: message.role == .person ? .trailing : .leading, spacing: 4) {
                Text(message.text)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(
                        message.role == .person ? Color.blue : Color(.systemGray5),
                        in: RoundedRectangle(cornerRadius: 18)
                    )
                    .foregroundStyle(message.role == .person ? .white : .primary)

                Text(message.timestamp, format: .dateTime.hour().minute())
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 8)
            }

            if message.role == .agent {
                Spacer(minLength: 50)
            }
        }
    }
}

struct MessageInputView: View {
    @Binding var messageText: String
    let onSend: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            TextField("Message", text: $messageText, axis: .vertical)
                .textFieldStyle(.roundedBorder)
                .lineLimit(1...5)
                .onSubmit {
                    onSend()
                }

            Button(action: onSend) {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.title2)
                    .foregroundStyle(messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? Color.secondary : Color.blue)
            }
            .disabled(messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        }
        .padding()
        .background(.regularMaterial)
    }
}

struct TypingIndicator: View {
    @State private var animationPhase = 0

    var body: some View {
        HStack {
            HStack(spacing: 4) {
                ForEach(0..<3, id: \.self) { index in
                    Circle()
                        .fill(.secondary)
                        .frame(width: 8, height: 8)
                        .scaleEffect(animationPhase == index ? 1.2 : 0.8)
                        .animation(
                            .easeInOut(duration: 0.6).repeatForever().delay(Double(index) * 0.2),
                            value: animationPhase
                        )
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(Color(.systemGray5), in: RoundedRectangle(cornerRadius: 18))

            Spacer(minLength: 50)
        }
        .onAppear {
            animationPhase = 0
            withAnimation {
                animationPhase = 1
            }
        }
    }
}

#Preview {
    let sampleConversation = Conversation(title: "Sample Chat")
    let sampleMessage1 = Message(text: "Hello, how are you?", role: .person)
    let sampleMessage2 = Message(text: "I'm doing well, thank you! How can I help you today?", role: .agent)

    sampleMessage1.conversation = sampleConversation
    sampleMessage2.conversation = sampleConversation
    sampleConversation.messages = [sampleMessage1, sampleMessage2]

    return NavigationStack {
        ChatView(conversation: sampleConversation)
    }
    .modelContainer(for: [Conversation.self, Message.self, Provider.self, LLM.self, MessageAttachment.self])
}
