//
   //  ImageLoaderTests.swift
   //  NASAAPODAppTests
   //
   //  Created by Praveen UK on 03/10/2025.
   //
   
   import XCTest
   @testable import NASAAPODApp
   
   final class ImageLoaderTests: XCTestCase {
   
       var imageLoader: ImageLoader!
           var mockClient: MockNetworkClient!
           var mockCache: MockImageCache!
           
           override func setUp() {
               super.setUp()
               mockClient = MockNetworkClient()
               mockCache = MockImageCache()
               imageLoader = ImageLoader(client: mockClient, cache: mockCache)
           }
           
           override func tearDown() {
               imageLoader = nil
               mockClient = nil
               mockCache = nil
               super.tearDown()
           }
           
           func testImageLoader_LoadFromCache() async {
               // Given
               let testImage = UIImage(systemName: "star.fill")!
               let testURL = URL(string: "https://example.com/cached.jpg")!
               mockCache.cachedImages[testURL.absoluteString] = testImage
               
               // When
               let loaded = await imageLoader.loadImage(from: testURL)
               
               // Then
               XCTAssertEqual(loaded, testImage)
               XCTAssertFalse(mockClient.performRequestCalled) // Should NOT hit network
           }
           
           func testImageLoader_LoadFromNetwork() async {
               // Given
               let testURL = URL(string: "https://example.com/network.jpg")!
               let imageData = UIImage(systemName: "photo")!.pngData()!
               mockClient.dataToReturn = imageData
               mockClient.responseToReturn = HTTPURLResponse(
                   url: testURL,
                   statusCode: 200,
                   httpVersion: nil,
                   headerFields: nil
               )
               
               // When
               let loaded = await imageLoader.loadImage(from: testURL)
               
               // Then
               XCTAssertNotNil(loaded)
               XCTAssertTrue(mockClient.performRequestCalled)
               XCTAssertTrue(mockCache.saveCalled)
           }
           
           func testImageLoader_NetworkFailure() async {
               // Given
               let testURL = URL(string: "https://example.com/fail.jpg")!
               mockClient.errorToThrow = URLError(.notConnectedToInternet)
               
               // When
               let loaded = await imageLoader.loadImage(from: testURL)
               
               // Then
               XCTAssertNil(loaded)
           }
           
           func testImageLoader_InvalidImageData() async {
               // Given
               let testURL = URL(string: "https://example.com/invalid.jpg")!
               mockClient.dataToReturn = "invalid image data".data(using: .utf8)!
               mockClient.responseToReturn = HTTPURLResponse(
                   url: testURL,
                   statusCode: 200,
                   httpVersion: nil,
                   headerFields: nil
               )
               
               // When
               let loaded = await imageLoader.loadImage(from: testURL)
               
               // Then
               XCTAssertNil(loaded)
               XCTAssertFalse(mockCache.saveCalled) // Should not cache invalid image
           }
           
           func testImageLoader_CacheHitDoesNotCallNetwork() async {
               // Given
               let testImage = UIImage(systemName: "heart.fill")!
               let testURL = URL(string: "https://example.com/cached2.jpg")!
               mockCache.cachedImages[testURL.absoluteString] = testImage
               
               // When
               let loaded = await imageLoader.loadImage(from: testURL)
               
               // Then
               XCTAssertNotNil(loaded)
               XCTAssertTrue(mockCache.loadCalled)
               XCTAssertFalse(mockClient.performRequestCalled)
           }
   
   }
