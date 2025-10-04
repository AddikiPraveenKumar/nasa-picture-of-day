//
//  NetworkClient.swift
//  NASAAPODApp
//
//  Created by Praveen UK on 01/10/2025.
//

import Foundation
class NetworkClient: NetworkClientProtocol {
    private let session: URLSessionProtocol
    
    init(session: URLSessionProtocol = URLSession.shared) {
        self.session = session
    }
    
    func performRequest(url: URL) async throws -> (Data, URLResponse) {
        do {
            return try await session.data(from: url)
        } catch let urlError as URLError {
            // Handle specific URL errors
            switch urlError.code {
            case .notConnectedToInternet, .networkConnectionLost:
                throw NetworkError.networkError(urlError)
            case .timedOut:
                throw NetworkError.networkError(urlError)
            default:
                throw NetworkError.networkError(urlError)
            }
        } catch {
            throw NetworkError.networkError(error)
        }
    }
}
