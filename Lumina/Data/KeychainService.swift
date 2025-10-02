//
//  KeychainService.swift
//  Lumina
//
//  Created by Mikael Weiss on 10/2/25.
//

import Foundation
import Security

/// Service for securely storing and retrieving API keys in the iOS Keychain
enum KeychainService {

    // MARK: - Error Types

    enum KeychainError: Error, LocalizedError {
        case saveFailed(OSStatus)
        case retrievalFailed(OSStatus)
        case deleteFailed(OSStatus)
        case invalidData

        var errorDescription: String? {
            switch self {
            case .saveFailed(let status):
                return "Failed to save to Keychain: \(status)"
            case .retrievalFailed(let status):
                return "Failed to retrieve from Keychain: \(status)"
            case .deleteFailed(let status):
                return "Failed to delete from Keychain: \(status)"
            case .invalidData:
                return "Invalid data retrieved from Keychain"
            }
        }
    }

    // MARK: - Constants

    private static let service = "com.lumina.api-keys"

    // MARK: - Public Methods

    /// Saves an API key securely to the Keychain
    /// - Parameters:
    ///   - apiKey: The API key to store
    ///   - providerId: The unique identifier for the provider
    /// - Throws: KeychainError if save fails
    static func saveAPIKey(_ apiKey: String, for providerId: UUID) throws {
        guard let data = apiKey.data(using: .utf8) else {
            throw KeychainError.invalidData
        }

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: providerId.uuidString,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlocked
        ]

        // Delete any existing item first
        SecItemDelete(query as CFDictionary)

        // Add new item
        let status = SecItemAdd(query as CFDictionary, nil)

        guard status == errSecSuccess else {
            throw KeychainError.saveFailed(status)
        }
    }

    /// Retrieves an API key from the Keychain
    /// - Parameter providerId: The unique identifier for the provider
    /// - Returns: The API key if found, nil otherwise
    /// - Throws: KeychainError if retrieval fails (excluding item not found)
    static func getAPIKey(for providerId: UUID) throws -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: providerId.uuidString,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        // Item not found is not an error - just return nil
        guard status != errSecItemNotFound else {
            return nil
        }

        guard status == errSecSuccess else {
            throw KeychainError.retrievalFailed(status)
        }

        guard let data = result as? Data,
              let apiKey = String(data: data, encoding: .utf8) else {
            throw KeychainError.invalidData
        }

        return apiKey
    }

    /// Deletes an API key from the Keychain
    /// - Parameter providerId: The unique identifier for the provider
    /// - Throws: KeychainError if deletion fails
    static func deleteAPIKey(for providerId: UUID) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: providerId.uuidString
        ]

        let status = SecItemDelete(query as CFDictionary)

        // Item not found is not an error when deleting
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw KeychainError.deleteFailed(status)
        }
    }

    /// Checks if an API key exists for a provider
    /// - Parameter providerId: The unique identifier for the provider
    /// - Returns: True if an API key exists, false otherwise
    static func hasAPIKey(for providerId: UUID) -> Bool {
        do {
            return try getAPIKey(for: providerId) != nil
        } catch {
            return false
        }
    }
}
