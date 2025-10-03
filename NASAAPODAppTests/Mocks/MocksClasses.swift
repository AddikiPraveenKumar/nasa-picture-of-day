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
    var apodToReturn: APOD?
    var shouldFail = false
    var requestedDate: Date?
    var delay: TimeInterval = 0
    
    func fetchAPOD(for date: Date?) async throws -> APOD {
        requestedDate = date
        
        if delay > 0 {
            try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
        }
        
        if shouldFail {
            throw NetworkError.networkError(NSError(domain: "Test", code: -1009))
        }
        
        guard let apod = apodToReturn else {
            throw NetworkError.noData
        }
        
        return apod
    }
}

class MockAPODCache: APODCacheProtocol {
    var cachedAPOD: APOD?
    var saveCalled = false
    var loadCalled = false
    
    func save(_ apod: APOD) throws {
        saveCalled = true
        cachedAPOD = apod
    }
    
    func load() -> APOD? {
        loadCalled = true
        return cachedAPOD
    }
    
    func clear() {
        cachedAPOD = nil
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

class MockImageLoader: ImageLoaderProtocol {
    var imageToReturn: UIImage?
    var loadCalled = false
    var delay: TimeInterval = 0
    
    func loadImage(from url: URL) async -> UIImage? {
        loadCalled = true
        
        if delay > 0 {
            try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
        }
        
        return imageToReturn
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
