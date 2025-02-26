//
//  ChatViewModel.swift
//  Lumina
//
//  Created by Mikael Weiss on 2/24/25.
//

import Foundation
import OSLog
import SwiftData

@MainActor
@Observable
class ChatViewModel {
    // MARK: - Properties
    
    private let chatService: ChatServiceProtocol
    private let storageManager = StorageManager.shared
    
    var conversations: [Conversation] = []
    var currentConversation: Conversation
    var messageText: String = ""
    var inturrupted = false
    var isLoading: Bool {
        sendMessageTask != nil
    }
    var errorMessage: String?
    private var sendMessageTask: Task<Void, Error>?
    var showConfirmDeleteConversation = false
    private var conversationToDelete: Conversation?
    
    // MARK: - Initialization
    
    init(chatService: ChatServiceProtocol) {
        self.chatService = chatService
        currentConversation = Conversation()
        loadConversations()
    }
    
    // MARK: - Conversation Management
    
    func loadConversations() {
        let descriptor = FetchDescriptor<StorageConversation>(sortBy: [SortDescriptor(\.createdAt, order: .reverse)])
        let storageConversations = storageManager.fetch(descriptor)
        conversations = storageConversations.map { $0.toDomainModel() }
    }
    
    func createNewConversation(title: String = "New Conversation") {
        let conversation = chatService.createConversation(title: title)
        currentConversation = conversation
        
        let storageConversation = StorageConversation.fromDomainModel(conversation)
        storageManager.insert(storageConversation)
        loadConversations()
    }
    
    func selectConversation(_ conversation: Conversation) {
        currentConversation = conversation
    }
    
    func updateConversationTitle(newTitle: String) {
        // Update the current conversation
        var updatedConversation = currentConversation
        updatedConversation.title = newTitle
        updatedConversation.updatedAt = Date()
        currentConversation = updatedConversation
        
        // Update in storage
        let descriptor = FetchDescriptor<StorageConversation>(
            predicate: #Predicate { $0.id == updatedConversation.id }
        )
        
        if let storageConversation = storageManager.fetch(descriptor).first {
            storageConversation.title = newTitle
            storageConversation.updatedAt = Date()
            try? storageManager.save()
            loadConversations()
        }
    }
    
    func deleteCurrentConversation() {
        let descriptor = FetchDescriptor<StorageConversation>(
            predicate: #Predicate { $0.id == currentConversation.id }
        )
        
        if let storageConversation = storageManager.fetch(descriptor).first {
            storageManager.delete(storageConversation)
            currentConversation = Conversation()
            loadConversations()
        }
    }
    
    func didTapDelete(_ conversation: Conversation) {
        showConfirmDeleteConversation = true
        conversationToDelete = conversation
    }
    
    func deleteSwipedConversation() {
        guard let conversationToDelete else { return }
        
        let descriptor = FetchDescriptor<StorageConversation>(
            predicate: #Predicate { $0.id == conversationToDelete.id }
        )
        
        if let storageConversation = storageManager.fetch(descriptor).first {
            storageManager.delete(storageConversation)
            self.conversationToDelete = nil
            
            if conversationToDelete.id == currentConversation.id {
                currentConversation = Conversation()
            }
            
            loadConversations()
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
        
        let userMessage = Message(role: .user, content: messageText)
        currentConversation.messages.append(userMessage)
        messageText = ""
        errorMessage = nil
        
        // Save the updated conversation with the user message
        saveCurrentConversation()
        
        sendMessageTask = Task {
            defer {
                sendMessageTask = nil
            }
            do {
                let assistantResponse = try await chatService.sendMessage(for: currentConversation)
                currentConversation.messages.append(assistantResponse)
                saveCurrentConversation()
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
    
    // MARK: - Private Helpers
    
    private func saveCurrentConversation() {
        let descriptor = FetchDescriptor<StorageConversation>(
            predicate: #Predicate { $0.id == currentConversation.id }
        )
        
        if let storageConversation = storageManager.fetch(descriptor).first {
            // Update existing conversation
            storageConversation.messages = currentConversation.messages.map { StorageMessage.fromDomainModel($0) }
            storageConversation.updatedAt = Date()
        } else {
            // Create new conversation
            let storageConversation = StorageConversation.fromDomainModel(currentConversation)
            storageManager.insert(storageConversation)
        }
        
        try? storageManager.save()
        loadConversations()
    }
} 
