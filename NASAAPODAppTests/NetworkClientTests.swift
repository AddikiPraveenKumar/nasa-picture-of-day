//
//  NetworkClientTests.swift
//  NASAAPODAppTests
//
//  Created by Praveen UK on 03/10/2025.
//

import XCTest
@testable import NASAAPODApp

final class NetworkClientTests: XCTestCase {
    var networkClient: NetworkClient!
    var mockSession: MockURLSession!
    
    override func setUp() {
        super.setUp()
        mockSession = MockURLSession()
        networkClient = NetworkClient(session: mockSession)
    }
    
    override func tearDown() {
        networkClient = nil
        mockSession = nil
        super.tearDown()
    }
    
    func testPerformRequest_Success() async throws {
        // Given - Using generic test URL (no actual network call)
        let testURL = URL(string: "https://mock-api.test/endpoint")!
        let expectedData = "mock response data".data(using: .utf8)!
        let expectedResponse = HTTPURLResponse(
            url: testURL,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )!
        
        // Mock returns predefined data - NO ACTUAL NETWORK CALL
        mockSession.dataToReturn = expectedData
        mockSession.responseToReturn = expectedResponse
        
        // When
        let (data, response) = try await networkClient.performRequest(url: testURL)
        
        // Then - Verifies NetworkClient passes through mock data correctly
        XCTAssertEqual(data, expectedData)
        XCTAssertEqual(response as? HTTPURLResponse, expectedResponse)
        XCTAssertTrue(mockSession.dataFromURLCalled)
    }
    
    func testPerformRequest_NetworkError() async {
        // Given - Generic test URL, mock will simulate network error
        let testURL = URL(string: "https://mock-api.test/endpoint")!
        let underlyingError = URLError(.notConnectedToInternet)
        mockSession.errorToThrow = underlyingError
        
        // When/Then - Tests NetworkClient error wrapping (NO ACTUAL NETWORK CALL)
        do {
            _ = try await networkClient.performRequest(url: testURL)
            XCTFail("Should throw NetworkError")
        } catch let error as NetworkError {
            // This tests the line: throw NetworkError.networkError(error)
            if case .networkError(let wrappedError) = error {
                XCTAssertEqual((wrappedError as? URLError)?.code, URLError.Code.notConnectedToInternet)
            } else {
                XCTFail("Wrong NetworkError type")
            }
        } catch {
            XCTFail("Should throw NetworkError, got: \(error)")
        }
    }
    
    func testPerformRequest_TimeoutError() async {
        // Given - Mock simulates timeout (VPN/network independent)
        let testURL = URL(string: "https://mock-api.test/timeout")!
        let timeoutError = URLError(.timedOut)
        mockSession.errorToThrow = timeoutError
        
        // When/Then - Tests error wrapping for timeout scenarios
        do {
            _ = try await networkClient.performRequest(url: testURL)
            XCTFail("Should throw NetworkError")
        } catch let error as NetworkError {
            if case .networkError(let wrappedError) = error {
                XCTAssertEqual((wrappedError as? URLError)?.code, URLError.Code.timedOut)
            } else {
                XCTFail("Wrong NetworkError type")
            }
        } catch {
            XCTFail("Should throw NetworkError")
        }
    }
    
    func testPerformRequest_GenericURLError() async {
        // Given - Tests any URLError gets wrapped properly
        let testURL = URL(string: "https://mock-api.test/generic-error")!
        let genericError = URLError(.cannotFindHost)
        mockSession.errorToThrow = genericError
        
        // When/Then - Verifies NetworkClient wraps ANY URLError
        do {
            _ = try await networkClient.performRequest(url: testURL)
            XCTFail("Should throw NetworkError")
        } catch let error as NetworkError {
            if case .networkError(let wrappedError) = error {
                XCTAssertEqual((wrappedError as? URLError)?.code, URLError.Code.cannotFindHost)
            } else {
                XCTFail("Wrong NetworkError type")
            }
        } catch {
            XCTFail("Should throw NetworkError")
        }
    }
}

