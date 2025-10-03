//
//  NetworkClientProtocol.swift
//  NASAAPODApp
//
//  Created by Praveen UK on 01/10/2025.
//

// MARK: - Protocols/NetworkClientProtocol.swift
import Foundation

enum NetworkError: Error, LocalizedError {
    case invalidURL
    case noData
    case decodingError
    case invalidDate
    case rateLimitExceeded
    case serverError(statusCode: Int)
    case networkError(Error)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .noData:
            return "No data received"
        case .decodingError:
            return "Failed to decode response"
        case .invalidDate:
            return "APOD not available for this date. Try an earlier date."
        case .rateLimitExceeded:
            return "API rate limit exceeded. Please wait or use your own API key."
        case .serverError(let code):
            return "Server error: \(code)"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        }
    }
}

protocol URLSessionProtocol {
    func data(from url: URL) async throws -> (Data, URLResponse)
}

// Make URLSession conform to our protocol
extension URLSession: URLSessionProtocol {}

protocol NetworkClientProtocol {
    func performRequest(url: URL) async throws -> (Data, URLResponse)
}
