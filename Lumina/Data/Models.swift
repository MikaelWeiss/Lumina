//
//  Models.swift
//  Lumina
//
//  Created by Mikael Weiss on 9/27/25.
//

import Foundation
import SwiftData

// MARK: - Supporting Enums

enum MessageRole: String, Codable, CaseIterable {
    case agent = "agent"
    case person = "person"
}

enum InputType: String, Codable, CaseIterable {
    case text = "text"
    case image = "image"
    case audio = "audio"
    case file = "file"
    case video = "video"
}

enum OutputType: String, Codable, CaseIterable {
    case text = "text"
    case image = "image"
    case audio = "audio"
    case file = "file"
    case video = "video"
}

enum AttachmentType: String, Codable, CaseIterable {
    case image = "image"
    case audio = "audio"
    case file = "file"
    case video = "video"
}

// MARK: - Provider Model

@Model
class Provider {
    private(set) var id = UUID()
    var name = ""
    var endpoint = ""
    var apiKeyURL: String?
    var sortOrder = 0

    @Relationship(deleteRule: .cascade, inverse: \LLM.provider)
    var availableLLMs = [LLM]()

    init(name: String = "", endpoint: String = "", apiKeyURL: String? = nil, sortOrder: Int = 0) {
        self.name = name
        self.endpoint = endpoint
        self.apiKeyURL = apiKeyURL
        self.sortOrder = sortOrder
    }

    /// Check if this provider has an API key stored in the Keychain
    var hasAPIKey: Bool {
        KeychainService.hasAPIKey(for: self.id)
    }

    /// Get the API key for this provider from the Keychain
    func getAPIKey() throws -> String? {
        try KeychainService.getAPIKey(for: self.id)
    }

    /// Save an API key for this provider to the Keychain
    func saveAPIKey(_ apiKey: String) throws {
        try KeychainService.saveAPIKey(apiKey, for: self.id)
    }

    /// Delete the API key for this provider from the Keychain
    func deleteAPIKey() throws {
        try KeychainService.deleteAPIKey(for: self.id)
    }
}

// MARK: - LLM Model

@Model
class LLM {
    private(set) var id = UUID()
    var name = ""
    var inputTypes = [InputType]()
    var outputTypes = [OutputType]()
    var isEnabledForChat = false

    var provider: Provider?

    init(name: String = "", inputTypes: [InputType] = [], outputTypes: [OutputType] = [], isEnabledForChat: Bool = false) {
        self.name = name
        self.inputTypes = inputTypes
        self.outputTypes = outputTypes
        self.isEnabledForChat = isEnabledForChat
    }
}

// MARK: - MessageAttachment Model

@Model
class MessageAttachment {
    private(set) var id = UUID()
    var type: AttachmentType = AttachmentType.file
    var fileName: String?
    var fileData: Data?
    var filePath: String?

    var message: Message?

    init(
        type: AttachmentType = AttachmentType.file, fileName: String? = nil, fileData: Data? = nil,
        filePath: String? = nil
    ) {
        self.type = type
        self.fileName = fileName
        self.fileData = fileData
        self.filePath = filePath
    }
}

// MARK: - Conversation Model

@Model
class Conversation {
    private(set) var id = UUID()
    var title = "New Conversation"
    var systemPrompt = ""
    var temperature: Double? = nil
    var topP: Double? = nil
    var isArchived = false
    var createdAt = Date()
    var updatedAt = Date()

    var provider: Provider?
    var selectedLLM: LLM?

    @Relationship(deleteRule: .cascade, inverse: \Message.conversation)
    var messages = [Message]()

    init() {}

    init(title: String, systemPrompt: String = "", temperature: Double = 1.0, topP: Double = 1.0) {
        self.title = title
        self.systemPrompt = systemPrompt
        self.temperature = temperature
        self.topP = topP
        self.updatedAt = Date()
    }
}

// MARK: - Message Model

@Model
class Message {
    private(set) var id = UUID()
    var text = ""
    var role: MessageRole = MessageRole.person
    var timestamp = Date()
    var audioData: Data?
    var thinkingEffort: String?
    var cost: Double?
    var tokenCount: Int?

    var conversation: Conversation?

    @Relationship(deleteRule: .cascade, inverse: \MessageAttachment.message)
    var attachments = [MessageAttachment]()

    init() {}

    init(text: String, role: MessageRole = MessageRole.person) {
        self.text = text
        self.role = role
    }
}

