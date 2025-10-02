//
//  SettingsView.swift
//  Lumina
//
//  Created by Mikael Weiss on 10/2/25.
//

import SwiftUI
import StoreKit

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.requestReview) private var requestReview

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    NavigationLink(destination: SystemPromptView()) {
                        NavRowContent(title: "General Settings", icon: "gear")
                    }
                    Button {
                        requestReview()
                    } label: {
                        HStack {
                            Image(systemName: "star.fill")
                                .foregroundStyle(Color.accentColor)
                                .font(.title3)
                                .padding(.trailing, 6)
                            Text("Rate Lumina")
                                .foregroundStyle(.primary)
                            Spacer()
                        }
                    }
                }

                Section {
                    NavigationLink(destination: ProvidersView()) {
                        NavRowContent(title: "LLM Providers", icon: "cpu")
                    }
                }

                Section {
                    NavigationLink(destination: AboutView()) {
                        NavRowContent(title: "About Weiss Solutions", icon: "info.circle")
                    }
                    NavigationLink(destination: PrivacyPolicyView()) {
                        NavRowContent(title: "Privacy Policy", icon: "lock.shield")
                    }
                    NavigationLink(destination: TermsOfServiceView()) {
                        NavRowContent(title: "Terms of Service", icon: "doc.text")
                    }
                }

                Section {
                    VStack(spacing: 4) {
                        Text("© 2025 Weiss Solutions LLC")
                            .font(.system(size: 12, weight: .regular, design: .rounded))

                        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String,
                           let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
                            Text("Version \(version) (\(build))")
                                .font(.system(size: 12, weight: .regular, design: .rounded))
                                .foregroundStyle(Color.secondary)
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
                .listRowBackground(Color.clear)
            }
            .fontWeight(.medium)
            .navigationTitle("Settings")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }

    struct NavRowContent: View {
        let title: String
        let icon: String

        var body: some View {
            HStack {
                Image(systemName: icon)
                    .foregroundStyle(Color.accentColor)
                    .font(.title3)
                    .padding(.trailing, 6)
                Text(title)
            }
        }
    }
}

#Preview {
    SettingsView()
}
