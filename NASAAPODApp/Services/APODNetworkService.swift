//
//  APODNetworkService.swift
//  NASAAPODApp
//
//  Created by Praveen UK on 01/10/2025.
//

import Foundation

// MARK: - HTTP Status Code
enum HTTPStatusCode: Int {
    case success = 200
    case badRequest = 400
    case unauthorized = 401
    case tooManyRequests = 429
    case serverError = 500
    
    var isSuccess: Bool {
        return (200...299).contains(rawValue)
    }
}

// MARK: - API Endpoints This Created for feature End points
enum APIEndpoint {
    case apod
    
    var path: String {
        switch self {
        case .apod:
            return "/apod"
        }
    }
}

// MARK: - Network Service
class APODNetworkService: APODServiceProtocol {
    private let client: NetworkClientProtocol
    private let baseURL: String
    
    init(client: NetworkClientProtocol) {
        self.client = client
        self.baseURL = ConfigManager.apiBaseURL
    }
    
    func fetchAPOD(for date: Date?) async throws -> APOD {
        guard let url = buildURL(for: .apod, date: date) else {
            throw NetworkError.invalidURL
        }
        print("+++++\(url)")
        
        let (data, response) = try await client.performRequest(url: url)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.noData
        }
        
        print(httpResponse.statusCode)
        
        let statusCode = HTTPStatusCode(rawValue: httpResponse.statusCode)
        
        switch statusCode {
        case .badRequest:
            throw NetworkError.invalidDate
        case .tooManyRequests:
            throw NetworkError.rateLimitExceeded
        case .some(let code) where code.isSuccess:
            break // Success, continue to decode
        default:
            throw NetworkError.serverError(statusCode: httpResponse.statusCode)
        }
        
        do {
            return try JSONDecoder().decode(APOD.self, from: data)
        } catch {
            throw NetworkError.decodingError
        }
    }
    
    private func buildURL(for endpoint: APIEndpoint, date: Date?) -> URL? {
        let fullURLString = baseURL + endpoint.path
        var components = URLComponents(string: fullURLString)
        var queryItems = [URLQueryItem(name: "api_key", value: ConfigManager.nasaAPIKey)]
        
        if let date = date {
            // Validate date is not in the future
            if date > Date() {
                return nil
            }
            queryItems.append(URLQueryItem(name: "date", value: date.toString()))
        }
        
        components?.queryItems = queryItems
        return components?.url
    }
}
