//
//  AboutView.swift
//  Lumina
//
//  Created by Mikael Weiss on 10/2/25.
//

import SwiftUI

struct AboutView: View {
    var body: some View {
        ScrollView {
            // Hero section
            VStack(spacing: 0) {
                ZStack {
                    Color.accentColor.opacity(0.8)
                    VStack(spacing: 16) {
                        Text("About Weiss Solutions")
                            .font(.system(size: 48, weight: .bold))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)

                        Text("Building tools that empower people to harness the power of AI.")
                            .font(.title2)
                            .foregroundColor(.white.opacity(0.9))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .padding(.vertical, 64)
                }

                // Mission section
                VStack(spacing: 16) {
                    Text("Our Mission")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(.primary)

                    Text("At Weiss Solutions, we believe AI should be accessible to everyone. Our mission is to create intuitive tools that help people leverage AI technology effectively and responsibly.")
                        .font(.title2)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .padding(.vertical, 64)

                // Values section
                ZStack {
                    Color.gray.opacity(0.1)
                    VStack(spacing: 32) {
                        Text("Our Values")
                            .font(.system(size: 36, weight: .bold))
                            .foregroundColor(.primary)

                        VStack(spacing: 32) {
                            ValueCard(
                                icon: "bolt.fill",
                                title: "Innovation",
                                description: "We constantly push boundaries to create solutions that make a real difference in people's lives."
                            )

                            ValueCard(
                                icon: "person.2.fill",
                                title: "User-Focused",
                                description: "Every feature we build starts with understanding our users' needs and challenges."
                            )

                            ValueCard(
                                icon: "checkmark.shield.fill",
                                title: "Quality",
                                description: "We're committed to delivering reliable, high-quality software that our users can depend on."
                            )
                        }
                    }
                    .padding(.vertical, 64)
                    .padding(.horizontal)
                }

                // Story section
                VStack(spacing: 16) {
                    Text("Our Story")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(.primary)

                    Text("Founded in 2024, Weiss Solutions LLC is dedicated to making technology more accessible and useful. From productivity tools like Strive Planner to AI assistants like Lumina, we're committed to creating software that enhances people's capabilities.")
                        .font(.title2)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .padding(.vertical, 64)
            }
        }
        .ignoresSafeArea()
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct ValueCard: View {
    let icon: String
    let title: String
    let description: String

    var body: some View {
        VStack(spacing: 16) {
            ZStack {
                Color.accentColor
                    .frame(width: 48, height: 48)
                    .cornerRadius(8)

                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(.white)
                    .accessibilityLabel(title)
            }

            Text(title)
                .font(.title2.bold())
                .foregroundColor(.primary)

            Text(description)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
    }
}

#Preview {
    NavigationStack {
        AboutView()
    }
}
