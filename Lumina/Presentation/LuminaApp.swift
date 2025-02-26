//
//  LuminaApp.swift
//  Lumina
//
//  Created by Mikael Weiss on 2/24/25.
//

import SwiftUI
import SwiftData

@main
struct LuminaApp: App {
    var body: some Scene {
        WindowGroup {
            ChatView()
        }
        .modelContainer(StorageManager.shared.container)
    }
}
