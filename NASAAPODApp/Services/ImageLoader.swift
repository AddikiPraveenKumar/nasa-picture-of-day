import UIKit

class ImageLoader: ImageLoaderProtocol {
    private let client: NetworkClientProtocol
    private let cache: ImageCacheProtocol
    
    init(client: NetworkClientProtocol, cache: ImageCacheProtocol) {
        self.client = client
        self.cache = cache
    }
    
    func loadImage(from url: URL) async -> UIImage? {
        let key = url.absoluteString
        
        // Check cache first
        if let cached = cache.load(forKey: key) {
            return cached
        }
        
        // Download from network
        do {
            let (data, _) = try await client.performRequest(url: url)
            if let image = UIImage(data: data) {
                cache.save(image, forKey: key)
                return image
            }
        } catch {
            print("Failed to load image: \(error)")
        }
        
        return nil
    }
}
