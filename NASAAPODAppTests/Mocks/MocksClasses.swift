//
//  MocksClasses.swift
//  NASAAPODAppTests
//
//  Created by Praveen UK on 03/10/2025.
//

import Foundation
import SwiftUI
@testable import NASAAPODApp
class MockAPODService: APODServiceProtocol {
    var mockAPOD: APOD?
    var shouldFail = false
    var delay: TimeInterval = 0
    var errorToThrow: Error = NetworkError.noData
    
    func fetchAPOD(for date: Date?) async throws -> APOD {
        if delay > 0 {
            try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
        }
        
        if shouldFail {
            throw errorToThrow
        }
        
        guard let apod = mockAPOD else {
            throw NetworkError.noData
        }
        
        return apod
    }
}

class MockAPODCache: APODCacheProtocol {
    var mockAPOD: APOD?
    var saveCalled = false
    var loadCalled = false
    var clearCalled = false
    var savedAPOD: APOD?
    
    func save(_ apod: APOD) throws {
        saveCalled = true
        savedAPOD = apod
    }
    
    func load() -> APOD? {
        loadCalled = true
        return mockAPOD
    }
    
    func clear() {
        clearCalled = true
    }
}

class MockImageLoader: ImageLoaderProtocol {
    var mockImage: UIImage?
    var loadCalled = false
    var delay: TimeInterval = 0
    
    func loadImage(from url: URL) async -> UIImage? {
        loadCalled = true
        
        if delay > 0 {
            try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
        }
        
        return mockImage ?? UIImage(systemName: "photo")
    }
}


class MockImageCache: ImageCacheProtocol {
    var cachedImages: [String: UIImage] = [:]
    var saveCalled = false
    var loadCalled = false
    
    func save(_ image: UIImage, forKey key: String) {
        saveCalled = true
        cachedImages[key] = image
    }
    
    func load(forKey key: String) -> UIImage? {
        loadCalled = true
        return cachedImages[key]
    }
    
    func clear() {
        cachedImages.removeAll()
    }
}

class MockNetworkClient: NetworkClientProtocol {
    var dataToReturn: Data = Data()
    var responseToReturn: URLResponse?
    var errorToThrow: Error?
    var performRequestCalled = false
    
    func performRequest(url: URL) async throws -> (Data, URLResponse) {
        performRequestCalled = true
        
        if let error = errorToThrow {
            throw error
        }
        
        guard let response = responseToReturn else {
            throw URLError(.badServerResponse)
        }
        
        return (dataToReturn, response)
    }
}

class MockURLSession: URLSessionProtocol {
    var dataToReturn: Data = Data()
    var responseToReturn: URLResponse = URLResponse()
    var errorToThrow: Error?
    var dataFromURLCalled = false
    
    func data(from url: URL) async throws -> (Data, URLResponse) {
        dataFromURLCalled = true
        
        if let error = errorToThrow {
            throw error
        }
        
        return (dataToReturn, responseToReturn)
    }
}
