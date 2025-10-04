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
        
        do {
            // Try to fetch from API
            let apod = try await apodService.fetchAPOD(for: date)
            currentAPOD = apod
            
            // Cache APOD data
            try? apodCache.save(apod)
            
            isLoading = false
            
            // Load image sequentially (NOT in separate Task)
            if !apod.isVideo, let imageURL = apod.imageURL {
                isLoadingImage = true
                cachedImage = await imageLoader.loadImage(from: imageURL)
                isLoadingImage = false
            }
            
        } catch {
            // Service call failed - load from cache
            errorMessage = error.localizedDescription
            
            // Load cached APOD
            if let cached = apodCache.load() {
                currentAPOD = cached
                
                // Load cached image
                if !cached.isVideo, let imageURL = cached.imageURL {
                    isLoadingImage = true
                    cachedImage = await imageLoader.loadImage(from: imageURL)
                    isLoadingImage = false
                }
            }
            
            isLoading = false
        }
    }
}
