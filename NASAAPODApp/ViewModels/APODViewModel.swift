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
        isLoading = true
        errorMessage = nil
        cachedImage = nil // Clear previous image
        
        do {
            let apod = try await apodService.fetchAPOD(for: date)
            currentAPOD = apod
            try? apodCache.save(apod)
            isLoading = false
            
            // Load image concurrently
            if !apod.isVideo, let imageURL = apod.imageURL {
                Task {
                    isLoadingImage = true
                    cachedImage = await imageLoader.loadImage(from: imageURL)
                    isLoadingImage = false
                }
            }
        } catch {
            handleError(error)
        }
    }

    private func handleError(_ error: Error) {
        errorMessage = error.localizedDescription
        if let cached = apodCache.load() {
            currentAPOD = cached
            if !cached.isVideo, let imageURL = cached.imageURL {
                Task {
                    cachedImage = await imageLoader.loadImage(from: imageURL)
                }
            }
        }
        isLoading = false
    }
}
