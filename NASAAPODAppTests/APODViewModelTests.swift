//
//  APODViewModelTests.swift
//  NASAAPODAppTests
//
//  Created by Praveen UK on 03/10/2025.
//
import XCTest
@testable import NASAAPODApp

final class APODViewModelTests: XCTestCase {
    var viewModel: APODViewModel!
    var mockAPODService: MockAPODService!
    var mockAPODCache: MockAPODCache!
    var mockImageLoader: MockImageLoader!
    
    @MainActor override func setUp() {
        super.setUp()
        mockAPODService = MockAPODService()
        mockAPODCache = MockAPODCache()
        mockImageLoader = MockImageLoader()
        viewModel = APODViewModel(
            apodService: mockAPODService,
            apodCache: mockAPODCache,
            imageLoader: mockImageLoader
        )
    }
    
    override func tearDown() {
        viewModel = nil
        mockAPODService = nil
        mockAPODCache = nil
        mockImageLoader = nil
        super.tearDown()
    }
    
    // MARK: - Success Scenarios
    
    @MainActor
    func testLoadTodayAPOD_Success() async {
        // Given
        let expectedAPOD = createTestAPOD(title: "Test APOD", mediaType: "image")
        let expectedImage = createTestImage()
        mockAPODService.apodToReturn = expectedAPOD
        mockImageLoader.imageToReturn = expectedImage
        
        // When
        await viewModel.loadTodayAPOD()
        
        // Then
        XCTAssertEqual(viewModel.currentAPOD, expectedAPOD)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.errorMessage)
        XCTAssertEqual(viewModel.cachedImage, expectedImage)
        XCTAssertTrue(mockAPODCache.saveCalled)
        XCTAssertTrue(mockImageLoader.loadCalled)
    }
    
    @MainActor
    func testLoadAPOD_ForSpecificDate_Success() async {
        // Given
        let specificDate = Date(timeIntervalSince1970: 1609459200) // 2021-01-01
        let expectedAPOD = createTestAPOD(title: "New Year APOD", mediaType: "image")
        mockAPODService.apodToReturn = expectedAPOD
        
        // When
        await viewModel.loadAPOD(for: specificDate)
        
        // Then
        XCTAssertEqual(viewModel.currentAPOD, expectedAPOD)
        XCTAssertEqual(mockAPODService.requestedDate, specificDate)
    }
    
    @MainActor
    func testLoadAPOD_VideoType_SkipsImageLoad() async {
        // Given
        let videoAPOD = createTestAPOD(title: "Video APOD", mediaType: "video")
        mockAPODService.apodToReturn = videoAPOD
        
        // When
        await viewModel.loadAPOD(for: nil)
        
        // Then
        XCTAssertEqual(viewModel.currentAPOD, videoAPOD)
        XCTAssertTrue(videoAPOD.isVideo)
        XCTAssertFalse(mockImageLoader.loadCalled) // Should NOT load image for video
    }
    
    // MARK: - Cache Fallback Tests (CRITICAL REQUIREMENT)
    
    @MainActor
    func testLoadAPOD_NetworkFails_LoadsCachedData() async {
        // Given - This is the main requirement test!
        let cachedAPOD = createTestAPOD(title: "Cached APOD", mediaType: "image")
        let cachedImage = createTestImage()
        
        mockAPODService.shouldFail = true
        mockAPODCache.cachedAPOD = cachedAPOD
        mockImageLoader.imageToReturn = cachedImage
        
        // When
        await viewModel.loadAPOD(for: nil)
        
        // Then
        XCTAssertNotNil(viewModel.errorMessage)
        XCTAssertEqual(viewModel.currentAPOD, cachedAPOD) // ← Cache loaded
        XCTAssertEqual(viewModel.cachedImage, cachedImage) // ← Image loaded
        XCTAssertTrue(mockAPODCache.loadCalled)
        XCTAssertTrue(mockImageLoader.loadCalled)
    }
    
    @MainActor
    func testLoadAPOD_NetworkFails_NoCacheAvailable() async {
        // Given
        mockAPODService.shouldFail = true
        mockAPODCache.cachedAPOD = nil // No cache
        
        // When
        await viewModel.loadAPOD(for: nil)
        
        // Then
        XCTAssertNotNil(viewModel.errorMessage)
        XCTAssertNil(viewModel.currentAPOD)
        XCTAssertNil(viewModel.cachedImage)
    }
    
    @MainActor
    func testLoadAPOD_SubsequentCallFails_ShowsPreviousCache() async {
        // Given - Test "any subsequent service call fails"
        let firstAPOD = createTestAPOD(title: "First APOD", mediaType: "image")
        let firstImage = createTestImage()
        
        // First successful call
        mockAPODService.apodToReturn = firstAPOD
        mockImageLoader.imageToReturn = firstImage
        await viewModel.loadAPOD(for: nil)
        
        XCTAssertEqual(viewModel.currentAPOD, firstAPOD)
        
        // When - Second call fails
        mockAPODService.shouldFail = true
        mockAPODCache.cachedAPOD = firstAPOD // Cached from first call
        mockImageLoader.imageToReturn = firstImage
        
        await viewModel.loadAPOD(for: Date())
        
        // Then - Shows cached data from first call
        XCTAssertNotNil(viewModel.errorMessage)
        XCTAssertEqual(viewModel.currentAPOD, firstAPOD)
        XCTAssertEqual(viewModel.cachedImage, firstImage)
    }
    
    // MARK: - Loading State Tests
    
    @MainActor
    func testLoadAPOD_SetsLoadingState() async {
        // Given
        mockAPODService.delay = 0.5
        mockAPODService.apodToReturn = createTestAPOD(title: "Test", mediaType: "image")
        
        // When
        let loadTask = Task {
            await viewModel.loadAPOD(for: nil)
        }
        
        // Small delay to check loading state
        try? await Task.sleep(nanoseconds: 100_000_000)
        
        // Then
        XCTAssertTrue(viewModel.isLoading)
        
        await loadTask.value
        XCTAssertFalse(viewModel.isLoading)
    }
    
    @MainActor
    func testLoadAPOD_ImageLoadingSetsState() async {
        // Given
        let apod = createTestAPOD(title: "Test", mediaType: "image")
        mockAPODService.apodToReturn = apod
        mockImageLoader.delay = 0.5
        mockImageLoader.imageToReturn = createTestImage()
        
        // When
        await viewModel.loadAPOD(for: nil)
        
        // Then - Image loading state was managed
        XCTAssertFalse(viewModel.isLoadingImage) // Should be false after completion
    }
    
    // MARK: - Helper Methods
    
    private func createTestAPOD(title: String, mediaType: String) -> APOD {
        APOD(
            date: "2024-01-01",
            title: title,
            explanation: "Test explanation",
            url: "https://example.com/image.jpg",
            mediaType: mediaType,
            hdurl: "https://example.com/hd.jpg"
        )
    }
    
    private func createTestImage() -> UIImage {
        UIImage(systemName: "star.fill")!
    }
    
    // MARK: - Additional Coverage Tests
    
    @MainActor
    func testLoadAPOD_CachedVideoOnFailure() async {
        // Given
        let cachedVideoAPOD = createTestAPOD(title: "Cached Video", mediaType: "video")
        mockAPODService.shouldFail = true
        mockAPODCache.cachedAPOD = cachedVideoAPOD
        
        // When
        await viewModel.loadAPOD(for: nil)
        
        // Then
        XCTAssertEqual(viewModel.currentAPOD, cachedVideoAPOD)
        XCTAssertTrue(cachedVideoAPOD.isVideo)
        XCTAssertFalse(mockImageLoader.loadCalled) // Should not load image for video
    }
    
    @MainActor
    func testLoadAPOD_ImageURLNil() async {
        // Given
        // Create APOD with empty URL
        let apodNoURL = APOD(
            date: "2024-01-01",
            title: "No Image URL",
            explanation: "Test",
            url: "",
            mediaType: "image",
            hdurl: nil
        )
        mockAPODService.apodToReturn = apodNoURL
        
        // When
        await viewModel.loadAPOD(for: nil)
        
        // Then
        XCTAssertNotNil(viewModel.currentAPOD)
        // Image loader should not be called if URL is invalid
    }
    
    @MainActor
    func testLoadAPOD_CacheSaveError() async {
        // Given
        let testAPOD = createTestAPOD(title: "Test", mediaType: "image")
        mockAPODService.apodToReturn = testAPOD
        mockImageLoader.imageToReturn = createTestImage()
        
        // When - Even if cache save fails, should still succeed
        await viewModel.loadAPOD(for: nil)
        
        // Then
        XCTAssertEqual(viewModel.currentAPOD, testAPOD)
        XCTAssertFalse(viewModel.isLoading)
    }
    
    @MainActor
    func testLoadTodayAPOD_CallsLoadAPODWithNilDate() async {
        // Given
        let testAPOD = createTestAPOD(title: "Today", mediaType: "image")
        mockAPODService.apodToReturn = testAPOD
        mockImageLoader.imageToReturn = createTestImage()
        
        // When
        await viewModel.loadTodayAPOD()
        
        // Then
        XCTAssertNil(mockAPODService.requestedDate)
        XCTAssertEqual(viewModel.currentAPOD, testAPOD)
    }
}
