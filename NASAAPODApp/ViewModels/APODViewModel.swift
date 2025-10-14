//
//  APODViewModel.swift
//  NASAAPODApp
//
//  Created by Praveen UK on 01/10/2025.
//

import Foundation
import UIKit
import Combine

@MainActor
class APODViewModel: ObservableObject {
    @Published var currentAPOD: APOD?
    @Published var isLoading = false
    @Published var isLoadingImage = false
    @Published var errorMessage: String?
    @Published var cachedImage: UIImage?
    
    private let apodService: APODServiceProtocol
    private let apodCache: APODCacheProtocol
    private let imageLoader: ImageLoaderProtocol
    
    private var currentLoadTask: Task<Void, Never>?
   
    private let timeoutDuration: TimeInterval = 15.0
    
    init(
        apodService: APODServiceProtocol,
        apodCache: APODCacheProtocol,
        imageLoader: ImageLoaderProtocol
    ) {
        self.apodService = apodService
        self.apodCache = apodCache
        self.imageLoader = imageLoader
    }
    
    convenience init() {
        let networkClient = NetworkClient()
        let apodService = APODNetworkService(client: networkClient)
        let apodCache = APODCacheService()
        let imageCache = ImageCacheService()
        let imageLoader = ImageLoader(client: networkClient, cache: imageCache)
        
        self.init(
            apodService: apodService,
            apodCache: apodCache,
            imageLoader: imageLoader
        )
    }
    
    func loadTodayAPOD() async {
        await loadAPOD(for: nil)
    }
    
    func loadAPOD(for date: Date?) async {
        currentLoadTask?.cancel()
        
        currentLoadTask = Task {
            await performLoad(for: date)
        }
        
        await currentLoadTask?.value
    }
    
    private func performLoad(for date: Date?) async {
        isLoading = true
        errorMessage = nil
        cachedImage = nil
        
        do {
            let apod = try await withTimeout(seconds: timeoutDuration) {
                try await self.apodService.fetchAPOD(for: date)
            }
            
        // Check for cancellation
            guard !Task.isCancelled else {
                isLoading = false
                return
            }
            
     // Success! Got data from API
            currentAPOD = apod
            errorMessage = nil
            
            // Cache the APOD data
            do {
                apodCache.clear()
                try apodCache.save(apod)
            } catch {
                print("Failed to cache APOD: \(error.localizedDescription)")
            }
            
            isLoading = false
            
            // Load image
            await loadImage(for: apod)
            
        } catch is TimeoutError {
            print("API timeout after 15 seconds - loading from cache")
            errorMessage = "Request timed out after 15 seconds"
            await loadFromCache()
            
        } catch {
            print("API error: \(error.localizedDescription) - loading from cache")
            errorMessage = error.localizedDescription
            await loadFromCache()
        }
    }
    
    private func loadFromCache() async {
        guard !Task.isCancelled else {
            isLoading = false
            return
        }
        
        if let cached = apodCache.load() {
            currentAPOD = cached
            print("Loaded APOD from cache")
                        
            await loadImage(for: cached)
        } else {
            errorMessage = "No cached data available"
            print(" No cache available")
        }
        
        isLoading = false
    }
    
    private func loadImage(for apod: APOD) async {
        guard !Task.isCancelled else { return }
        
        if !apod.isVideo, let imageURL = apod.imageURL {
            isLoadingImage = true
            
            do {
                let image = try await withTimeout(seconds: timeoutDuration) {
                    await self.imageLoader.loadImage(from: imageURL)
                }
                
                guard !Task.isCancelled else {
                    isLoadingImage = false
                    return
                }
                
                cachedImage = image
                
            } catch is TimeoutError {
                print("Image load timeout")
                cachedImage = nil
            } catch {
                print("Image load error: \(error)")
                cachedImage = nil
            }
            
            isLoadingImage = false
        }
    }
    
    // Timeout helper function
    private func withTimeout<T>(
        seconds: TimeInterval,
        operation: @escaping () async throws -> T
    ) async throws -> T {
        try await withThrowingTaskGroup(of: T.self) { group in
            // Task 1: The actual operation
            group.addTask {
                try await operation()
            }
            
            // Task 2: Timeout
            group.addTask {
                try await Task.sleep(nanoseconds: UInt64(seconds * 1_000_000_000))
                throw TimeoutError()
            }
            
            // Return the first result (either success or timeout)
            let result = try await group.next()!
            
            // Cancel the other task
            group.cancelAll()
            
            return result
        }
    }
    
    // Cleanup
    deinit {
        currentLoadTask?.cancel()
        print("APODViewModel deallocated")
    }
}

// Custom timeout error
struct TimeoutError: Error, LocalizedError {
    var errorDescription: String? {
        return "Request timed out after 15 seconds"
    }
}
