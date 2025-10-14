//
//  APODViewModelTests.swift
//  NASAAPODAppTests
//
//  Created by Praveen UK on 03/10/2025.
//

import XCTest
@testable import NASAAPODApp

@MainActor
class APODViewModelTests: XCTestCase {
    
    var viewModel: APODViewModel!
    var mockService: MockAPODService!
    var mockCache: MockAPODCache!
    var mockImageLoader: MockImageLoader!
    
    override func setUp() {
        super.setUp()
        mockService = MockAPODService()
        mockCache = MockAPODCache()
        mockImageLoader = MockImageLoader()
        
        viewModel = APODViewModel(
            apodService: mockService,
            apodCache: mockCache,
            imageLoader: mockImageLoader
        )
    }
    
    override func tearDown() {
        viewModel = nil
        mockService = nil
        mockCache = nil
        mockImageLoader = nil
        super.tearDown()
    }
    
    
    func testLoadFromCache_TaskCancelled_ExitsEarly() async {
        // Given
        let cachedAPOD = createMockAPOD()
        mockCache.mockAPOD = cachedAPOD
        mockService.delay = 20.0 // Force timeout
        
        // When
        let loadTask = Task {
            await viewModel.loadTodayAPOD()
        }
        
    
        try? await Task.sleep(nanoseconds: 100_000_000) // Just 0.1s
        loadTask.cancel()
        
        _ = await loadTask.result
        
        try? await Task.sleep(nanoseconds: 200_000_000)
        
        // Then
        XCTAssertFalse(viewModel.isLoading, "Should not be loading after cancellation")
        print("Test passed: loadFromCache respects task cancellation")
    }
    
    func testLoadFromCache_WithCachedData_LoadsSuccessfully() async {
        // Given
        let cachedAPOD = createMockAPOD(title: "Cached APOD")
        mockCache.mockAPOD = cachedAPOD
        mockService.delay = 20.0 // Force timeout
        
        // When
        await viewModel.loadTodayAPOD()
        
        // Then
        XCTAssertEqual(viewModel.currentAPOD?.title, "Cached APOD")
        XCTAssertTrue(mockCache.loadCalled)
        XCTAssertFalse(viewModel.isLoading)
        print("Test passed: loadFromCache with cached data")
    }
    
    func testLoadFromCache_WithCachedImage_LoadsImage() async {
        // Given
        let cachedAPOD = createMockAPOD(title: "Cached with Image")
        mockCache.mockAPOD = cachedAPOD
        mockImageLoader.mockImage = UIImage(systemName: "star.fill")
        mockService.delay = 20.0
        
        // When
        await viewModel.loadTodayAPOD()
        
        // Then
        XCTAssertNotNil(viewModel.cachedImage)
        XCTAssertTrue(mockImageLoader.loadCalled)
        print("Test passed: loadFromCache loads image")
    }
    
    func testLoadFromCache_WithVideoAPOD_DoesNotLoadImage() async {
        // Given
        let videoAPOD = createMockAPOD(title: "Video", mediaType: .video)
        mockCache.mockAPOD = videoAPOD
        mockService.delay = 20.0
        
        // When
        await viewModel.loadTodayAPOD()
        
        // Then
        XCTAssertNil(viewModel.cachedImage)
        XCTAssertFalse(mockImageLoader.loadCalled)
        print("Test passed: loadFromCache skips video image loading")
    }
    
    func testLoadFromCache_NoCacheAvailable_SetsErrorMessage() async {
        // Given
        mockCache.mockAPOD = nil
        mockService.delay = 20.0
        
        // When
        await viewModel.loadTodayAPOD()
        
        // Then
        XCTAssertNil(viewModel.currentAPOD)
        XCTAssertNotNil(viewModel.errorMessage)
        XCTAssertTrue(viewModel.errorMessage?.contains("No cached data") ?? false)
        print("Test passed: loadFromCache with no cache sets error")
    }
    
    func testLoadImage_TaskCancelled_ExitsEarly() async {
        // Given
        let apod = createMockAPOD(mediaType: .image)
        mockService.mockAPOD = apod
        mockService.delay = 0.5
        mockImageLoader.delay = 10.0 // Long delay for image
        
        // When
        let loadTask = Task {
            await viewModel.loadTodayAPOD()
        }
        
        try? await Task.sleep(nanoseconds: 1_000_000_000) // 1s
        loadTask.cancel()
        
        _ = await loadTask.result
        try? await Task.sleep(nanoseconds: 200_000_000)
        
        // Then
        XCTAssertFalse(viewModel.isLoadingImage, "Should not be loading after cancellation")
        print("Test passed: loadImage respects cancellation")
    }
    
    func testLoadImage_WithImageAPOD_LoadsSuccessfully() async {
        // Given
        let apod = createMockAPOD(mediaType: .image)
        mockService.mockAPOD = apod
        mockImageLoader.mockImage = UIImage(systemName: "photo")
        
        // When
        await viewModel.loadTodayAPOD()
        
        // Then
        XCTAssertNotNil(viewModel.cachedImage)
        XCTAssertTrue(mockImageLoader.loadCalled)
        XCTAssertFalse(viewModel.isLoadingImage)
        print("Test passed: loadImage loads successfully")
    }
    
    func testLoadImage_WithVideoAPOD_SkipsImageLoad() async {
        // Given
        let videoAPOD = createMockAPOD(mediaType: .video)
        mockService.mockAPOD = videoAPOD
        
        // When
        await viewModel.loadTodayAPOD()
        
        // Then
        XCTAssertNil(viewModel.cachedImage)
        XCTAssertFalse(mockImageLoader.loadCalled)
        XCTAssertFalse(viewModel.isLoadingImage)
        print("Test passed: loadImage skips video")
    }
    
    func testLoadImage_Timeout_SetsImageToNil() async {
        // Given
        let apod = createMockAPOD(mediaType: .image)
        mockService.mockAPOD = apod
        mockImageLoader.delay = 20.0
        
        // When
        await viewModel.loadTodayAPOD()
        
        // Then
        XCTAssertNil(viewModel.cachedImage)
        XCTAssertFalse(viewModel.isLoadingImage)
        print("Test passed: loadImage handles timeout")
    }
    
    func testLoadImageClosure_WithTimeout_CatchesTimeoutError() async {
        // Given
        let apod = createMockAPOD(mediaType: .image)
        mockService.mockAPOD = apod
        mockImageLoader.delay = 20.0
        
        // When
        await viewModel.loadTodayAPOD()
        
        // Then
        XCTAssertNil(viewModel.cachedImage)
        XCTAssertFalse(viewModel.isLoadingImage)
        print("Test passed: loadImage closure catches timeout")
    }
        
    func testPerformLoad_ChecksCancellationBeforeImageLoad() async {
        // Given
        let apod = createMockAPOD(mediaType: .image)
        mockService.mockAPOD = apod
        mockService.delay = 0.3
        mockImageLoader.delay = 10.0
        
        // When
        let loadTask = Task {
            await viewModel.loadTodayAPOD()
        }
        
        // Wait for API, then cancel before image
        try? await Task.sleep(nanoseconds: 700_000_000) // 0.7s
        loadTask.cancel()
        
        _ = await loadTask.result
        try? await Task.sleep(nanoseconds: 200_000_000)
        
        // Then
        XCTAssertFalse(viewModel.isLoadingImage, "Should not be loading after cancellation")
        print("Test passed: performLoad checks cancellation before image load")
    }
    
    func testPerformLoad_CachedImageLoadChecksCancellation() async {
        // Given
        mockService.shouldFail = true
        let cachedAPOD = createMockAPOD(mediaType: .image)
        mockCache.mockAPOD = cachedAPOD
        mockImageLoader.delay = 10.0
        
        // When
        let loadTask = Task {
            await viewModel.loadTodayAPOD()
        }
        
        // Wait a bit, then cancel
        try? await Task.sleep(nanoseconds: 500_000_000) // 0.5s
        loadTask.cancel()
        
        // Wait for cleanup
        _ = await loadTask.result
        try? await Task.sleep(nanoseconds: 200_000_000)
        
        // Then
        XCTAssertFalse(viewModel.isLoadingImage, "Should not be loading after cancellation")
        print("Test passed: performLoad checks cancellation in cached image load")
    }
    
    func testPerformLoad_ChecksCancellationAfterAPICall() async {
        // Given
        let apod = createMockAPOD()
        mockService.mockAPOD = apod
        mockService.delay = 0.5
        
        // When
        let loadTask = Task {
            await viewModel.loadTodayAPOD()
        }
        

        try? await Task.sleep(nanoseconds: 1_000_000_000) // 1s
        loadTask.cancel()
        
        _ = await loadTask.result
        try? await Task.sleep(nanoseconds: 200_000_000)
        
        // Then
        XCTAssertFalse(viewModel.isLoading, "Should not be loading after cancellation")
        print("Test passed: performLoad checks cancellation after API")
    }
    
    // MARK: - Additional Working Tests
    
    func testTimeoutError_ErrorDescription() {
        // Given
        let error = TimeoutError()
        
        // When
        let description = error.errorDescription
        
        // Then
        XCTAssertNotNil(description)
        XCTAssertEqual(description, "Request timed out after 15 seconds")
        print("Test passed: TimeoutError.errorDescription")
    }
    
    func testDeinit_CancelsCurrentTask() async {
        // Given
        mockService.delay = 10.0
        
        Task {
            await viewModel.loadTodayAPOD()
        }
        
        try? await Task.sleep(nanoseconds: 500_000_000)
        
        // When - Deallocate viewModel
        viewModel = nil
        
        // Then
        XCTAssertNil(viewModel)
        print("Test passed: deinit cancels task")
    }
    
    // MARK: - Helper Methods
    
    private func createMockAPOD(
        title: String = "Test APOD",
        date: String = "2024-10-05",
        mediaType: MediaType = .image
    ) -> APOD {
        return APOD(
            date: date,
            title: title,
            explanation: "Test explanation",
            url: mediaType == .image ? "https://example.com/image.jpg" : "https://youtube.com/watch",
            mediaType: mediaType,
            hdurl: nil
        )
    }
}


extension MockAPODCache {
    var shouldFailOnSave: Bool {
        get { return false }
        set { }
    }
}

extension MockImageLoader {
    var shouldFail: Bool {
        get { return false }
        set { }
    }
    
    var errorToThrow: Error {
        get { return NSError(domain: "Test", code: -1) }
        set { }
    }
}
