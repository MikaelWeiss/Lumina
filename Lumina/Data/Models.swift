//
//  Models.swift
//  Lumina
//
//  Created by Mikael Weiss on 9/27/25.
//

import Foundation
import SwiftData

@Model
class Conversation {
    private(set) var id = UUID()
    var title = "New Conversation"
    var messages = [Message]()

    init() {}
}

@Model
class Message {
    private(set) var id = UUID()
    var text = ""
    var timestamp = Date()

    init() {}
}
