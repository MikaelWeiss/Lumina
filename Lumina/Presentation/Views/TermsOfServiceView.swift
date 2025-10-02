//
//  TermsOfServiceView.swift
//  Lumina
//
//  Created by Mikael Weiss on 10/2/25.
//

import SwiftUI

struct TermsOfServiceView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 64) {
                // Header
                VStack(spacing: 16) {
                    Text("Terms of Service for Lumina iOS Application")
                        .font(.system(size: 32))
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.center)

                    Text("Effective Date: October 2, 2025")
                        .font(.system(size: 18))
                        .foregroundColor(.secondary)
                }

                // Content sections
                VStack(spacing: 48) {
                    // 1. Introduction
                    PolicySection(title: "1. Introduction") {
                        Text("Welcome to the Lumina iOS application (\"Lumina\" or \"App\"). These Terms of Service (\"Terms\") govern your access and use of the App provided by Weiss Solutions LLC (\"Company,\" \"we,\" \"our,\" or \"us\"). By downloading, accessing, or using the App, you agree to be bound by these Terms. If you do not agree to these Terms, you must not use the App.")
                    }

                    // 2. Acceptance of Terms
                    PolicySection(title: "2. Acceptance of Terms") {
                        Text("By using the App, you confirm that you:")
                        BulletPoint(text: "Have the authority to accept these Terms")
                        BulletPoint(text: "Will comply with these Terms and all applicable laws and regulations")
                        BulletPoint(text: "Understand that your use of the App is subject to our Privacy Policy")
                    }

                    // 3. License to Use the App
                    PolicySection(title: "3. License to Use the App") {
                        Text("We grant you a limited, non-exclusive, non-transferable, revocable license to use the App for personal, non-commercial purposes. You may not:")
                        BulletPoint(text: "Copy, modify, distribute, sell, or lease any part of the App")
                        BulletPoint(text: "Reverse engineer or attempt to extract the source code of the App")
                        BulletPoint(text: "Remove any copyright or proprietary notices from the App")
                        BulletPoint(text: "Transfer your license to another person")
                    }

                    // 4. Privacy and Data Protection
                    PolicySection(title: "4. Privacy and Data Protection") {
                        Text("Your use of the App is governed by our Privacy Policy, which explains how we handle your information. Key points include:")
                        BulletPoint(text: "Data storage is only on your device")
                        BulletPoint(text: "We do not collect or sell your personal information")
                        BulletPoint(text: "You retain ownership of your content")
                        BulletPoint(text: "Third-party AI providers have their own privacy policies")
                    }

                    // 5. User Content and Conduct
                    PolicySection(title: "5. User Content and Conduct") {
                        Text("You agree not to:")
                        BulletPoint(text: "Use the App for any unlawful purpose")
                        BulletPoint(text: "Use the App to generate harmful or malicious content")
                        BulletPoint(text: "Interfere with the App's operation or security")
                        BulletPoint(text: "Attempt to gain unauthorized access")
                        BulletPoint(text: "Violate third-party AI provider terms of service")
                    }

                    // 6. Third-Party AI Services
                    PolicySection(title: "6. Third-Party AI Services") {
                        Text("Lumina connects to third-party AI providers. You acknowledge that:")
                        BulletPoint(text: "You are responsible for complying with each provider's terms")
                        BulletPoint(text: "We are not responsible for third-party service availability or quality")
                        BulletPoint(text: "You must provide your own API keys for these services")
                        BulletPoint(text: "Third-party providers may charge fees for their services")
                    }

                    // 7. Intellectual Property Rights
                    PolicySection(title: "7. Intellectual Property Rights") {
                        Text("The App and its content are protected by copyright, trademark, and other laws. Our intellectual property includes:")
                        BulletPoint(text: "Software code")
                        BulletPoint(text: "Design elements")
                        BulletPoint(text: "User interface")
                        BulletPoint(text: "Logos and trademarks")
                    }

                    // 8. Disclaimers and Warranties
                    PolicySection(title: "8. Disclaimers and Warranties") {
                        Text("THE APP IS PROVIDED \"AS IS\" WITHOUT WARRANTIES OF ANY KIND. WE DISCLAIM ALL WARRANTIES, INCLUDING:")
                        BulletPoint(text: "Merchantability")
                        BulletPoint(text: "Fitness for a particular purpose")
                        BulletPoint(text: "Non-infringement")
                        BulletPoint(text: "Accuracy or reliability of AI-generated content")
                        BulletPoint(text: "Uninterrupted or error-free operation")
                    }

                    // 9. Limitation of Liability
                    PolicySection(title: "9. Limitation of Liability") {
                        Text("TO THE MAXIMUM EXTENT PERMITTED BY LAW, WE ARE NOT LIABLE FOR:")
                        BulletPoint(text: "Direct, indirect, or consequential damages")
                        BulletPoint(text: "Lost profits or data")
                        BulletPoint(text: "Damages arising from AI-generated content")
                        BulletPoint(text: "Third-party service failures")
                        BulletPoint(text: "Any damages arising from your use of the App")
                    }

                    // 10. Changes to Terms
                    PolicySection(title: "10. Changes to Terms") {
                        Text("We may modify these Terms:")
                        BulletPoint(text: "At any time with notice")
                        BulletPoint(text: "By posting updated Terms in the App")
                        BulletPoint(text: "Effective upon posting or specified date")
                        Text("Your continued use constitutes acceptance")
                            .padding(.top, 8)
                    }

                    // 11. Governing Law
                    PolicySection(title: "11. Governing Law") {
                        Text("These Terms are governed by:")
                        BulletPoint(text: "Laws of the United States")
                        BulletPoint(text: "Without regard to conflicts of law principles")
                        BulletPoint(text: "Exclusive jurisdiction in U.S. courts")
                    }

                    // 12. Contact Information
                    PolicySection(title: "12. Contact Information") {
                        Text("For questions about these Terms:")
                        Text("Email: legal@weisssolutions.io")
                            .foregroundColor(.accentColor)
                            .padding(.top, 4)
                    }

                    // 13. Acknowledgment
                    PolicySection(title: "13. Acknowledgment") {
                        Text("By using the App, you acknowledge that you have:")
                        BulletPoint(text: "Read these Terms")
                        BulletPoint(text: "Understood your obligations")
                        BulletPoint(text: "Agreed to be bound by them")
                        BulletPoint(text: "Consented to our Privacy Policy")

                        VStack(spacing: 8) {
                            Text("Thank you for using Lumina!")
                                .padding(.top, 16)
                            Text("Weiss Solutions LLC")
                                .foregroundColor(.accentColor)
                            Text("Last Updated: October 2, 2025")
                                .font(.system(size: 14))
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 48)
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        TermsOfServiceView()
    }
}
