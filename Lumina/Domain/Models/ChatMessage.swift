//
//  ChatMessage.swift
//  Lumina
//
//  Created by Mikael Weiss on 2/24/25.
//

import Foundation

struct ChatMessage: Identifiable {
    let id: String
    let content: String
    let isUser: Bool
    let timestamp: Date
    let senderName: String
    
    init(id: String = UUID().uuidString, 
         content: String, 
         isUser: Bool, 
         timestamp: Date = Date(),
         senderName: String = "") {
        self.id = id
        self.content = content
        self.isUser = isUser
        self.timestamp = timestamp
        self.senderName = senderName.isEmpty ? (isUser ? "You" : "Lumina") : senderName
    }
} 