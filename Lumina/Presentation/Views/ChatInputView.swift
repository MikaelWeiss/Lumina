//
//  ChatInputView.swift
//  Lumina
//
//  Created by Mikael Weiss on 3/1/25.
//

import SwiftUI

struct ChatInputView: View {
    @Binding var messageText: String
    let messageLoading: Bool
    let onSend: () -> Void
    @FocusState private var isFocused: Bool
    
    var body: some View {
        VStack(spacing: 12) {
            // Text input field
            TextField("Chat with Lumina", text: $messageText, axis: .vertical)
                .padding(.vertical, 10)
                .padding(.horizontal, 12)
                .focused($isFocused)
            
            // Send button (up arrow)
            Button(action: onSend) {
                Image(systemName: messageLoading ? "stop.circle.fill" : "arrow.up.circle.fill")
                    .resizable()
                    .foregroundColor(Color.accentColor)
                    .frame(width: 36, height: 36)
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(
            UnevenRoundedRectangle(
                topLeadingRadius: 24,
                bottomLeadingRadius: 0,
                bottomTrailingRadius: 0,
                topTrailingRadius: 24,
                style: .continuous)
            .fill(Color.secondary.opacity(0.1))
            .ignoresSafeArea(edges: [.bottom]))
        .onTapGesture {
            isFocused = true
        }
    }
}

#Preview {
    Spacer()
    ChatInputView(
        messageText: .constant("Hello world"),
        messageLoading: false,
        onSend: {}
    )
} 
