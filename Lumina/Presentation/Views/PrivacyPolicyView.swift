//
//  PrivacyPolicyView.swift
//  Lumina
//
//  Created by Mikael Weiss on 10/2/25.
//

import SwiftUI

struct PrivacyPolicyView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 64) {
                // Header
                VStack(spacing: 16) {
                    Text("Privacy Policy for Lumina iOS Application")
                        .font(.system(size: 32))
                        .foregroundStyle(Color.primary)
                        .multilineTextAlignment(.center)

                    Text("Last updated: October 2, 2025")
                        .font(.system(size: 18))
                        .foregroundStyle(Color.secondary)
                }

                // Content sections
                VStack(spacing: 48) {
                    // Introduction
                    PolicySection(title: "Introduction") {
                        Text("Welcome to Lumina! Your privacy is important to us. This Privacy Policy explains how Lumina handles your information. The short version: we don't collect or access your data.")
                        Text("By using Lumina, you agree to this Privacy Policy. If you don't agree, please don't use the app.")
                    }

                    // Data Storage and Privacy
                    PolicySection(title: "Data Storage and Privacy") {
                        BulletPoint(highlight: "Your Data Stays with You:", text: "Lumina does not collect, store, or process any user data on our servers. All information entered in the app, including conversations and settings, is securely stored locally on your device.")
                        BulletPoint(highlight: "API Keys:", text: "Any API keys you enter for AI providers are stored securely on your device and are never transmitted to Weiss Solutions servers. They are only used to communicate directly with your chosen AI provider.")
                    }

                    // Third-Party AI Services
                    PolicySection(title: "Third-Party AI Services") {
                        Text("Lumina allows you to connect to third-party AI providers (like OpenAI, Anthropic, etc.). When you use these services:")
                        BulletPoint(text: "Your conversations are sent directly to your chosen AI provider")
                        BulletPoint(text: "We do not have access to or store these conversations")
                        BulletPoint(text: "Each provider has their own privacy policy and terms of service")
                        BulletPoint(text: "You should review your chosen provider's privacy practices")
                    }

                    // Permissions
                    PolicySection(title: "Permissions") {
                        Text("Lumina may request the following permissions to enable core functionality:")
                        BulletPoint(text: "Network Access: To communicate with AI providers of your choice.")
                        Text("These permissions are solely for providing app functionality and are never used to collect or share your data.")
                            .padding(.top, 4)
                    }

                    // Privacy by Design
                    PolicySection(title: "Privacy by Design") {
                        Text("Lumina is built with privacy as a priority:")
                        BulletPoint(text: "No data collection or tracking by Weiss Solutions")
                        BulletPoint(text: "No user accounts or personal identifiers required")
                        BulletPoint(text: "All data stays on your device")
                    }

                    // Your Rights
                    PolicySection(title: "Your Rights") {
                        Text("Because Lumina does not access or store your data, we do not process or control any personal data. Therefore:")
                        BulletPoint(text: "We cannot access, modify, or delete your data")
                        BulletPoint(text: "You retain full ownership and control of all information saved in the app")
                    }

                    // Changes to Policy
                    PolicySection(title: "Changes to This Privacy Policy") {
                        Text("We may update this Privacy Policy from time to time. Any changes will be posted within the app, along with the updated effective date. Continued use of Lumina constitutes acceptance of the updated policy.")
                    }

                    // Contact
                    PolicySection(title: "Contact Us") {
                        Text("If you have questions or concerns about this Privacy Policy, you can contact us at:")
                        Text("privacy@weisssolutions.io")
                            .foregroundColor(.accentColor)
                    }

                    // Conclusion
                    PolicySection(title: "Conclusion") {
                        Text("Your privacy is our commitment. Lumina was built to help you without compromising your trust. Enjoy using the app knowing your data is yours alone.")
                        Text("Thank you for trusting Lumina!")
                            .padding(.top, 4)
                        Text("Weiss Solutions LLC")
                            .foregroundColor(.accentColor)
                            .padding(.top, 4)
                    }
                }
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 48)
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

// Helper Views
struct PolicySection<Content: View>: View {
    let title: String
    let content: Content

    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(title)
                .font(.system(size: 24))
                .foregroundColor(.primary)

            VStack(alignment: .leading, spacing: 8) {
                content
            }
            .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct BulletPoint: View {
    var highlight: String = ""
    let text: String

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Text("•")
            if !highlight.isEmpty {
                Text(highlight)
                    .foregroundColor(.accentColor)
                    .fontWeight(.medium)
                    + Text(" " + text)
            } else {
                Text(text)
            }
        }
    }
}

#Preview {
    NavigationStack {
        PrivacyPolicyView()
    }
}
