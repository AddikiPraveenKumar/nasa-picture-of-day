//
//  APODNetworkService.swift
//  NASAAPODApp
//
//  Created by Praveen UK on 01/10/2025.
//

import Foundation
class APODNetworkService: APODServiceProtocol {
    private let client: NetworkClientProtocol
    private let baseURL = "https://api.nasa.gov/planetary/apod"
    
    init(client: NetworkClientProtocol) {
        self.client = client
    }
    
    func fetchAPOD(for date: Date?) async throws -> APOD {
        guard let url = buildURL(for: date) else {
            throw NetworkError.invalidURL
        }
        print("+++++\(url)")
        
        let (data, response) = try await client.performRequest(url: url)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.noData
        }
        print(httpResponse.statusCode)
        if httpResponse.statusCode == 400 {
            throw NetworkError.invalidDate  // New error type
        } else if httpResponse.statusCode == 429 {
            throw NetworkError.rateLimitExceeded  // New error type
        } else if !(200...299).contains(httpResponse.statusCode) {
            throw NetworkError.serverError(statusCode: httpResponse.statusCode)
        }
        
        do {
            return try JSONDecoder().decode(APOD.self, from: data)
        } catch {
            throw NetworkError.decodingError
        }
    }
    
    private func buildURL(for date: Date?) -> URL? {
        var components = URLComponents(string: baseURL)
        var queryItems = [URLQueryItem(name: "api_key", value: KeyConfig.nasaAPIKey)]
        
        if let date = date {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            queryItems.append(URLQueryItem(name: "date", value: formatter.string(from: date)))
        }
        
        components?.queryItems = queryItems
        return components?.url
    }
}


struct KeyConfig {
    static var nasaAPIKey: String {
        guard let key = Bundle.main.infoDictionary?["NASA_API_KEY"] as? String else {
            fatalError("NASA_API_KEY not set in build configuration")
        }
        return key
    }
}
