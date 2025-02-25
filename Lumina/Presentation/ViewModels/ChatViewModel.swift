//
//  ChatViewModel.swift
//  Lumina
//
//  Created by Mikael Weiss on 2/24/25.
//

import Foundation
import OSLog

@Observable
class ChatViewModel {
    // MARK: - Properties
    
    private let chatService: ChatServiceProtocol
    
    var conversations: [Conversation] = []
    var currentConversation: Conversation
    var messageText: String = ""
    var inturrupted = false
    var isLoading: Bool {
        sendMessageTask != nil
    }
    var errorMessage: String?
    private var sendMessageTask: Task<Void, Error>?
    
    // MARK: - Initialization
    
    init(chatService: ChatServiceProtocol) {
        self.chatService = chatService
        currentConversation = Conversation()
        loadConversations()
        currentConversation = conversations.last ?? Conversation()
    }
    
    // MARK: - Conversation Management
    
    func loadConversations() {
        do {
            conversations = try chatService.loadConversations()
        } catch {
            errorMessage = "Failed to load conversations: \(error.localizedDescription)"
        }
    }
    
    func createNewConversation(title: String = "New Conversation") {
        let conversation = chatService.createConversation(title: title)
        currentConversation = conversation
        
        do {
            try chatService.saveConversation(conversation)
            loadConversations()
        } catch {
            errorMessage = "Failed to save new conversation: \(error.localizedDescription)"
        }
    }
    
    func selectConversation(_ conversation: Conversation) {
        currentConversation = conversation
    }
    
    func updateConversationTitle(newTitle: String) {
        do {
            currentConversation = try chatService.updateConversationTitle(currentConversation, newTitle: newTitle)
            loadConversations()
        } catch {
            errorMessage = "Failed to update conversation title: \(error.localizedDescription)"
        }
    }
    
    func deleteCurrentConversation() {
        do {
            try chatService.deleteConversation(currentConversation)
            currentConversation = Conversation()
            loadConversations()
        } catch {
            errorMessage = "Failed to delete conversation: \(error.localizedDescription)"
        }
    }
    
    // MARK: - Message Handling
    
    func didTapSendOrStop() async {
        if let sendMessageTask {
            sendMessageTask.cancel()
            inturrupted = true
            return
        }
        inturrupted = false
        guard !messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        let messageToSend = messageText
        messageText = ""
        errorMessage = nil
        let userMessage = Message(role: .user, content: messageToSend)
        currentConversation.messages.append(userMessage)
        
        sendMessageTask = Task {
            defer {
                sendMessageTask = nil
            }
            do {
                let assistantResponse = try await chatService.sendMessage(messageToSend, in: currentConversation)
                currentConversation.messages.append(assistantResponse)
                try chatService.saveConversation(currentConversation)
            } catch {
                if !Task.isCancelled {
                    errorMessage = "Failed to send message: \(error.localizedDescription)"
                }
            }
        }
    }
    
    // MARK: - API Key Validation
    
    func validateAPIKey() async -> Bool {
        do {
            return try await chatService.validateAPIKey()
        } catch {
            errorMessage = "API key validation failed: \(error.localizedDescription)"
            return false
        }
    }
} 
