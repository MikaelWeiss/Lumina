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
                    LazyVStack(spacing: 0) {
                        ForEach(conversation.messages) { message in
                            MessageRow(message: message)
                                .id(message.id)
                        }

                        if isTyping {
                            TypingIndicatorRow()
                        }
                    }
                    .padding(.vertical, 20)
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
        .background(Color(.systemBackground))
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

// MARK: - Avatar View

struct MessageAvatar: View {
    let role: MessageRole

    var body: some View {
        ZStack {
            Circle()
                .fill(role == .person ? Color.blue.opacity(0.1) : Color.green.opacity(0.1))
                .frame(width: 32, height: 32)

            Image(systemName: role == .person ? "person.fill" : "sparkles")
                .font(.system(size: 14))
                .foregroundStyle(role == .person ? .blue : .green)
                .accessibilityLabel(role == .person ? "User" : "AI Assistant")
        }
    }
}

// MARK: - Message Row

struct MessageRow: View {
    let message: Message
    @State private var appeared = false

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            MessageAvatar(role: message.role)

            VStack(alignment: .leading, spacing: 8) {
                Text(message.role == .person ? "You" : "AI")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.secondary)

                Text(message.text)
                    .font(.body)
                    .textSelection(.enabled)
                    .padding(.horizontal, message.role == .person ? 16 : 0)
                    .padding(.vertical, message.role == .person ? 12 : 0)
                    .background(
                        message.role == .person ?
                        AnyView(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.blue.opacity(0.1))
                        ) : AnyView(EmptyView())
                    )
                    .foregroundStyle(.primary)
            }
            .frame(maxWidth: 700, alignment: .leading)

            Spacer(minLength: 0)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity)
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 10)
        .onAppear {
            withAnimation(.easeOut(duration: 0.3)) {
                appeared = true
            }
        }
    }
}

// MARK: - Message Input

struct MessageInputView: View {
    @Binding var messageText: String
    let onSend: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            Divider()

            HStack(alignment: .bottom, spacing: 12) {
                TextField("Message", text: $messageText, axis: .vertical)
                    .textFieldStyle(.plain)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color(.systemGray6))
                    )
                    .lineLimit(1...6)
                    .onSubmit {
                        onSend()
                    }

                Button(action: onSend) {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.system(size: 32))
                        .foregroundStyle(
                            messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?
                            Color(.systemGray3) : Color.blue
                        )
                }
                .disabled(messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .background(Color(.systemBackground))
    }
}

// MARK: - Typing Indicator

struct TypingIndicatorRow: View {
    @State private var animationPhase = 0

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            MessageAvatar(role: .agent)

            VStack(alignment: .leading, spacing: 8) {
                Text("AI")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.secondary)

                HStack(spacing: 4) {
                    ForEach(0..<3, id: \.self) { index in
                        Circle()
                            .fill(Color(.systemGray3))
                            .frame(width: 8, height: 8)
                            .scaleEffect(animationPhase == index ? 1.2 : 0.8)
                            .animation(
                                .easeInOut(duration: 0.6).repeatForever().delay(Double(index) * 0.2),
                                value: animationPhase
                            )
                    }
                }
                .padding(.vertical, 8)
            }
            .frame(maxWidth: 700, alignment: .leading)

            Spacer(minLength: 0)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity)
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
