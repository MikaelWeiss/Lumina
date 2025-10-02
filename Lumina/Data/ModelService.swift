//
//  ModelService.swift
//  Lumina
//
//  Created by Mikael Weiss on 10/2/25.
//

import Foundation

/// Service for fetching available models from API providers
enum ModelService {

    // MARK: - Error Types

    enum ModelServiceError: Error, LocalizedError {
        case invalidURL
        case missingAPIKey
        case networkError(Error)
        case invalidResponse
        case decodingError(Error)

        var errorDescription: String? {
            switch self {
            case .invalidURL:
                return "Invalid provider endpoint URL"
            case .missingAPIKey:
                return "No API key found for this provider"
            case .networkError(let error):
                return "Network error: \(error.localizedDescription)"
            case .invalidResponse:
                return "Invalid response from provider"
            case .decodingError(let error):
                return "Failed to decode response: \(error.localizedDescription)"
            }
        }
    }

    // MARK: - Response Models

    struct ModelsResponse: Codable {
        let data: [ModelData]
    }

    struct ModelData: Codable {
        let id: String
    }

    // MARK: - Public Methods

    /// Fetches available models from a provider's /models endpoint
    /// - Parameter provider: The provider to fetch models from
    /// - Returns: Array of model names
    /// - Throws: ModelServiceError if fetch fails
    static func fetchModels(for provider: Provider) async throws -> [String] {
        // Get API key
        guard let apiKey = try provider.getAPIKey() else {
            throw ModelServiceError.missingAPIKey
        }

        // Construct URL
        let baseEndpoint = provider.endpoint.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        guard let url = URL(string: "\(baseEndpoint)/models") else {
            throw ModelServiceError.invalidURL
        }

        // Create request
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        // Perform request
        let (data, response) = try await URLSession.shared.data(for: request)

        // Validate response
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw ModelServiceError.invalidResponse
        }

        // Decode response
        do {
            let modelsResponse = try JSONDecoder().decode(ModelsResponse.self, from: data)
            return modelsResponse.data.map { $0.id }
        } catch {
            throw ModelServiceError.decodingError(error)
        }
    }
}
