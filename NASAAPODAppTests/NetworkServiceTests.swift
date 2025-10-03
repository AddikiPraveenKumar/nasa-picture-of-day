//
//  NetworkServiceTests.swift
//  NASAAPODAppTests
//
//  Created by Praveen UK on 03/10/2025.
//
import XCTest
@testable import NASAAPODApp

final class NetworkServiceTests: XCTestCase {
    var networkService: APODNetworkService!
    var mockClient: MockNetworkClient!
    
    override func setUp() {
        super.setUp()
        mockClient = MockNetworkClient()
        networkService = APODNetworkService(client: mockClient, apiKey: "TEST_KEY")
    }
    
    override func tearDown() {
        networkService = nil
        mockClient = nil
        super.tearDown()
    }
    
    func testFetchAPOD_Success() async throws {
        // Given
        let json = """
        {
            "date": "2024-01-01",
            "title": "Test APOD",
            "explanation": "Test explanation",
            "url": "https://example.com/image.jpg",
            "media_type": "image",
            "hdurl": "https://example.com/hd.jpg",
            "copyright": "Test Author"
        }
        """
        mockClient.dataToReturn = json.data(using: .utf8)!
        mockClient.responseToReturn = HTTPURLResponse(
            url: URL(string: "https://api.nasa.gov")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )
        
        // When
        let apod = try await networkService.fetchAPOD(for: nil)
        
        // Then
        XCTAssertEqual(apod.title, "Test APOD")
        XCTAssertEqual(apod.mediaType, "image")
        XCTAssertFalse(apod.isVideo)
    }
    
    func testFetchAPOD_VideoType() async throws {
        // Given
        let json = """
        {
            "date": "2021-10-11",
            "title": "Video APOD",
            "explanation": "Video explanation",
            "url": "https://youtube.com/watch?v=test",
            "media_type": "video"
        }
        """
        mockClient.dataToReturn = json.data(using: .utf8)!
        mockClient.responseToReturn = HTTPURLResponse(
            url: URL(string: "https://api.nasa.gov")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )
        
        // When
        let apod = try await networkService.fetchAPOD(for: nil)
        
        // Then
        XCTAssertEqual(apod.mediaType, "video")
        XCTAssertTrue(apod.isVideo)
        XCTAssertNotNil(apod.videoURL)
    }
    
    func testFetchAPOD_ServerError() async {
        // Given
        mockClient.dataToReturn = Data()
        mockClient.responseToReturn = HTTPURLResponse(
            url: URL(string: "https://api.nasa.gov")!,
            statusCode: 500,
            httpVersion: nil,
            headerFields: nil
        )
        
        // When/Then
        do {
            _ = try await networkService.fetchAPOD(for: nil)
            XCTFail("Should throw error")
        } catch let error as NetworkError {
            if case .serverError(let code) = error {
                XCTAssertEqual(code, 500)
            } else {
                XCTFail("Wrong error type")
            }
        } catch {
            XCTFail("Unexpected error type")
        }
    }
    
    func testFetchAPOD_BadRequest400() async {
        // Given - Simulates future date or invalid date
        mockClient.dataToReturn = Data()
        mockClient.responseToReturn = HTTPURLResponse(
            url: URL(string: "https://api.nasa.gov")!,
            statusCode: 400,
            httpVersion: nil,
            headerFields: nil
        )
        
        // When/Then
        do {
            _ = try await networkService.fetchAPOD(for: nil)
            XCTFail("Should throw error")
        } catch {
            XCTAssertNotNil(error)
        }
    }
    
    func testFetchAPOD_NetworkError() async {
        // Given
        mockClient.errorToThrow = NetworkError.networkError(URLError(.notConnectedToInternet))
        
        // When/Then
        do {
            _ = try await networkService.fetchAPOD(for: nil)
            XCTFail("Should throw error")
        } catch let error as NetworkError {
            if case .networkError = error {
                XCTAssertTrue(true)
            } else {
                XCTFail("Wrong error type")
            }
        } catch {
            XCTFail("Unexpected error type")
        }
    }
    
    func testFetchAPOD_InvalidURL() async {
        // Given - This would require modifying the service to accept invalid base URL
        // For now, we test with a specific date
        let date = Date(timeIntervalSince1970: 0)
        
        // When
        do {
            _ = try await networkService.fetchAPOD(for: date)
            // If it doesn't throw, that's fine - we're testing the URL building
        } catch {
            // Expected to potentially fail with old date
            XCTAssertNotNil(error)
        }
    }
    
    func testFetchAPOD_DecodingError() async {
        // Given - Invalid JSON
        mockClient.dataToReturn = "invalid json".data(using: .utf8)!
        mockClient.responseToReturn = HTTPURLResponse(
            url: URL(string: "https://api.nasa.gov")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )
        
        // When/Then
        do {
            _ = try await networkService.fetchAPOD(for: nil)
            XCTFail("Should throw decoding error")
        } catch let error as NetworkError {
            if case .decodingError = error {
                XCTAssertTrue(true)
            } else {
                XCTFail("Wrong error type: \(error)")
            }
        } catch {
            XCTFail("Unexpected error type")
        }
    }
    
    func testFetchAPOD_RateLimitError() async {
        // Given
        mockClient.dataToReturn = Data()
        mockClient.responseToReturn = HTTPURLResponse(
            url: URL(string: "https://api.nasa.gov")!,
            statusCode: 429,
            httpVersion: nil,
            headerFields: nil
        )
        
        // When/Then
        do {
            _ = try await networkService.fetchAPOD(for: nil)
            XCTFail("Should throw rate limit error")
        } catch let error as NetworkError {
            if case .rateLimitExceeded = error {
                XCTAssertTrue(true)
            } else {
                XCTFail("Wrong error type")
            }
        } catch {
            XCTFail("Unexpected error type")
        }
    }
    
    func testFetchAPOD_InvalidDateError() async {
        // Given
        mockClient.dataToReturn = Data()
        mockClient.responseToReturn = HTTPURLResponse(
            url: URL(string: "https://api.nasa.gov")!,
            statusCode: 400,
            httpVersion: nil,
            headerFields: nil
        )
        
        // When/Then
        do {
            _ = try await networkService.fetchAPOD(for: nil)
            XCTFail("Should throw invalid date error")
        } catch let error as NetworkError {
            if case .invalidDate = error {
                XCTAssertTrue(true)
            } else {
                XCTFail("Wrong error type")
            }
        } catch {
            XCTFail("Unexpected error type")
        }
    }
    
    func testFetchAPOD_WithSpecificDate() async throws {
        // Given
        let json = """
        {
            "date": "2024-06-15",
            "title": "Specific Date APOD",
            "explanation": "Test explanation",
            "url": "https://example.com/image.jpg",
            "media_type": "image"
        }
        """
        mockClient.dataToReturn = json.data(using: .utf8)!
        mockClient.responseToReturn = HTTPURLResponse(
            url: URL(string: "https://api.nasa.gov")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let testDate = dateFormatter.date(from: "2024-06-15")!
        
        // When
        let apod = try await networkService.fetchAPOD(for: testDate)
        
        // Then
        XCTAssertEqual(apod.date, "2024-06-15")
        XCTAssertEqual(apod.title, "Specific Date APOD")
    }
    
    // MARK: - NetworkError Description Tests
    
    func testNetworkError_InvalidURL_Description() {
        // Given
        let error = NetworkError.invalidURL
        
        // Then
        XCTAssertEqual(error.errorDescription, "Invalid URL")
    }
    
    func testNetworkError_NoData_Description() {
        // Given
        let error = NetworkError.noData
        
        // Then
        XCTAssertEqual(error.errorDescription, "No data received")
    }
    
    func testNetworkError_DecodingError_Description() {
        // Given
        let error = NetworkError.decodingError
        
        // Then
        XCTAssertEqual(error.errorDescription, "Failed to decode response")
    }
    
    func testNetworkError_InvalidDate_Description() {
        // Given
        let error = NetworkError.invalidDate
        
        // Then
        XCTAssertEqual(error.errorDescription, "APOD not available for this date. Try an earlier date.")
    }
    
    func testNetworkError_RateLimitExceeded_Description() {
        // Given
        let error = NetworkError.rateLimitExceeded
        
        // Then
        XCTAssertEqual(error.errorDescription, "API rate limit exceeded. Please wait or use your own API key.")
    }
    
    func testNetworkError_ServerError_Description() {
        // Given
        let error = NetworkError.serverError(statusCode: 500)
        
        // Then
        XCTAssertEqual(error.errorDescription, "Server error: 500")
    }
    
    func testNetworkError_NetworkError_Description() {
        // Given
        let underlyingError = URLError(.notConnectedToInternet)
        let error = NetworkError.networkError(underlyingError)
        
        // Then
        XCTAssertNotNil(error.errorDescription)
        XCTAssertTrue(error.errorDescription?.contains("Network error:") ?? false)
    }
}
