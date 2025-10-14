//
//  ImageCacheService.swift
//  NASAAPODApp
//
//  Created by Praveen UK on 01/10/2025.
//
import UIKit

class ImageCacheService: ImageCacheProtocol {
    private let fileManager = FileManager.default
    private lazy var imageCacheDirectory: URL? = {
        guard let cacheDir = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first else {
            return nil
        }
        let imageDir = cacheDir.appendingPathComponent("APODImages")
        
        if !fileManager.fileExists(atPath: imageDir.path) {
            try? fileManager.createDirectory(at: imageDir, withIntermediateDirectories: true)
        }
        
        return imageDir
    }()
    
    func save(_ image: UIImage, forKey key: String) {
        // Just save to disk - no memory cache
        guard let imageDirectory = imageCacheDirectory,
              let imageData = image.jpegData(compressionQuality: 0.8) else {
            return
        }
        
        let filename = key.simpleHash()
        let fileURL = imageDirectory.appendingPathComponent(filename)
        
        try? imageData.write(to: fileURL)
        print("Image cached to disk")
    }
    
    func load(forKey key: String) -> UIImage? {
        // Just load from disk - no memory cache check
        guard let imageDirectory = imageCacheDirectory else {
            return nil
        }
        
        let filename = key.simpleHash()
        let fileURL = imageDirectory.appendingPathComponent(filename)
        
        guard let imageData = try? Data(contentsOf: fileURL),
              let image = UIImage(data: imageData) else {
            return nil
        }
        
        print("Image loaded from disk cache")
        return image
    }
    
    func clear() {
        guard let imageDirectory = imageCacheDirectory else { return }
        try? fileManager.removeItem(at: imageDirectory)
    }
}

// Simpler hash function
extension String {
    func simpleHash() -> String {
        return String(format: "%08x", abs(self.hashValue))
    }
}
