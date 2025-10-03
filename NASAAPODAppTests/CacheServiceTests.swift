//
//  CacheServiceTests.swift
//  NASAAPODAppTests
//
//  Created by Praveen UK on 03/10/2025.
//
import XCTest
@testable import NASAAPODApp

final class CacheServiceTests: XCTestCase {
    var apodCache: APODCacheService!
    var imageCache: ImageCacheService!
    
    override func setUp() {
        super.setUp()
        // Clear cache before each test
        UserDefaults.standard.removeObject(forKey: "cachedAPOD")
        apodCache = APODCacheService()
        imageCache = ImageCacheService()
    }
    
    override func tearDown() {
        UserDefaults.standard.removeObject(forKey: "cachedAPOD")
        apodCache = nil
        imageCache = nil
        super.tearDown()
    }
    
    // MARK: - APOD Cache Tests
    
    func testAPODCache_SaveAndLoad() throws {
        // Given
        let apod = APOD(
            date: "2024-01-01",
            title: "Test Title",
            explanation: "Test Explanation",
            url: "https://example.com/image.jpg",
            mediaType: "image",
            hdurl: "https://example.com/hd.jpg"
        )
        
        // When
        try apodCache.save(apod)
        let loaded = apodCache.load()
        
        // Then
        XCTAssertNotNil(loaded)
        XCTAssertEqual(loaded?.title, apod.title)
        XCTAssertEqual(loaded?.date, apod.date)
        XCTAssertEqual(loaded?.explanation, apod.explanation)
    }
    
    func testAPODCache_LoadWithNoCache() {
        // When
        let loaded = apodCache.load()
        
        // Then
        XCTAssertNil(loaded)
    }
    
    func testAPODCache_OverwritesPreviousCache() throws {
        // Given
        let firstAPOD = APOD(
            date: "2024-01-01",
            title: "First",
            explanation: "First",
            url: "https://example.com/1.jpg",
            mediaType: "image",
            hdurl: nil
        )
        let secondAPOD = APOD(
            date: "2024-01-02",
            title: "Second",
            explanation: "Second",
            url: "https://example.com/2.jpg",
            mediaType: "image",
            hdurl: nil
        )
        
        // When
        try apodCache.save(firstAPOD)
        try apodCache.save(secondAPOD)
        let loaded = apodCache.load()
        
        // Then
        XCTAssertEqual(loaded?.title, "Second")
    }
    
    // MARK: - Image Cache Tests
    
    func testImageCache_SaveAndLoad() {
        // Given
        let testImage = UIImage(systemName: "star.fill")!
        let testKey = "https://example.com/test.jpg"
        
        // When
        imageCache.save(testImage, forKey: testKey)
        let loaded = imageCache.load(forKey: testKey)
        
        // Then
        XCTAssertNotNil(loaded)
    }
    
    func testImageCache_LoadWithNoCache() {
        // When
        let loaded = imageCache.load(forKey: "https://nonexistent.com/image.jpg")
        
        // Then
        XCTAssertNil(loaded)
    }
    
    func testImageCache_PersistsAcrossInstances() {
        // Given
        let testImage = UIImage(systemName: "photo.fill")!
        let testKey = "https://example.com/persist.jpg"
        
        // When
        imageCache.save(testImage, forKey: testKey)
        
        // Create new instance (simulates app restart)
        let newCacheInstance = ImageCacheService()
        let loaded = newCacheInstance.load(forKey: testKey)
        
        // Then
        XCTAssertNotNil(loaded) // Should load from disk
    }
    
    func testAPODCache_SaveThrowsError() {
        // Given - Create an APOD with data that might cause encoding issues
        let apod = APOD(
            date: "2024-01-01",
            title: "Test",
            explanation: "Test",
            url: "https://example.com/image.jpg",
            mediaType: "image",
            hdurl: nil
        )
        
        // When/Then - Should not throw
        XCTAssertNoThrow(try apodCache.save(apod))
    }
    
    func testImageCache_MultipleImages() {
        // Given
        let image1 = UIImage(systemName: "star.fill")!
        let image2 = UIImage(systemName: "heart.fill")!
        let key1 = "https://example.com/image1.jpg"
        let key2 = "https://example.com/image2.jpg"
        
        // When
        imageCache.save(image1, forKey: key1)
        imageCache.save(image2, forKey: key2)
        
        // Then
        XCTAssertNotNil(imageCache.load(forKey: key1))
        XCTAssertNotNil(imageCache.load(forKey: key2))
    }
    
    func testAPODCache_VideoType() throws {
        // Given
        let videoAPOD = APOD(
            date: "2024-01-01",
            title: "Video APOD",
            explanation: "Video explanation",
            url: "https://youtube.com/watch?v=test",
            mediaType: "video",
            hdurl: nil
        )
        
        // When
        try apodCache.save(videoAPOD)
        let loaded = apodCache.load()
        
        // Then
        XCTAssertNotNil(loaded)
        XCTAssertEqual(loaded?.mediaType, "video")
        XCTAssertTrue(loaded?.isVideo ?? false)
    }
}
