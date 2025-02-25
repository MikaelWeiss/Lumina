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
    var currentConversation: Conversation?
    var messageText: String = ""
    var isLoading: Bool = false
    var errorMessage: String?
    
    // MARK: - Initialization
    
    init(chatService: ChatServiceProtocol) {
        self.chatService = chatService
        loadConversations()
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
        guard let conversation = currentConversation else { return }
        
        do {
            currentConversation = try chatService.updateConversationTitle(conversation, newTitle: newTitle)
            loadConversations()
        } catch {
            errorMessage = "Failed to update conversation title: \(error.localizedDescription)"
        }
    }
    
    func deleteCurrentConversation() {
        guard let conversation = currentConversation else { return }
        
        do {
            try chatService.deleteConversation(conversation)
            currentConversation = nil
            loadConversations()
        } catch {
            errorMessage = "Failed to delete conversation: \(error.localizedDescription)"
        }
    }
    
    // MARK: - Message Handling
    
    func sendMessage() async {
        guard !messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              var conversation = currentConversation else { return }
        
        let messageToSend = messageText
        messageText = ""
        isLoading = true
        errorMessage = nil
        let userMessage = Message(role: .user, content: messageToSend)
        
        do {
            let assistantResponse = try await chatService.sendMessage(messageToSend, in: conversation)
            conversation.messages.append(userMessage)
            conversation.messages.append(assistantResponse)
            try chatService.saveConversation(conversation)
            currentConversation = conversation
        } catch {
            errorMessage = "Failed to send message: \(error.localizedDescription)"
        }
        
        isLoading = false
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
