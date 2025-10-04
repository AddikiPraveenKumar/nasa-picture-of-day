//
//  APODModelTests.swift
//  NASAAPODAppTests
//
//  Created by Praveen UK on 03/10/2025.
//

import XCTest
@testable import NASAAPODApp

final class APODModelTests: XCTestCase {

    func testAPOD_ImageType() {
            // Given
            let apod = APOD(
                date: "2024-01-01",
                title: "Test",
                explanation: "Test",
                url: "https://example.com/image.jpg",
                mediaType: .image,
                hdurl: "https://example.com/hd.jpg"
            )
            
            // Then
            XCTAssertFalse(apod.isVideo)
            XCTAssertNotNil(apod.imageURL)
            XCTAssertNil(apod.videoURL)
        }
        
        func testAPOD_VideoType() {
            // Given
            let apod = APOD(
                date: "2021-10-11",
                title: "Video",
                explanation: "Video",
                url: "https://youtube.com/watch?v=test",
                mediaType: .video,
                hdurl: nil
            )
            
            // Then
            XCTAssertTrue(apod.isVideo)
            XCTAssertNotNil(apod.videoURL)
        }
        
        func testAPOD_ImageURL_PrefersHDURL() {
            // Given
            let apod = APOD(
                date: "2024-01-01",
                title: "Test",
                explanation: "Test",
                url: "https://example.com/standard.jpg",
                mediaType: .image,
                hdurl: "https://example.com/hd.jpg"
            )
            
            // Then
            XCTAssertEqual(apod.imageURL?.absoluteString, "https://example.com/hd.jpg")
        }
        
        func testAPOD_ImageURL_FallsBackToStandardURL() {
            // Given
            let apod = APOD(
                date: "2024-01-01",
                title: "Test",
                explanation: "Test",
                url: "https://example.com/standard.jpg",
                mediaType: .image,
                hdurl: nil
            )
            
            // Then
            XCTAssertEqual(apod.imageURL?.absoluteString, "https://example.com/standard.jpg")
        }
        
        func testAPOD_Equatable() {
            // Given
            let apod1 = APOD(
                date: "2024-01-01",
                title: "Test",
                explanation: "Test",
                url: "https://example.com/image.jpg",
                mediaType: .image,
                hdurl: nil
            )
            let apod2 = APOD(
                date: "2024-01-01",
                title: "Test",
                explanation: "Test",
                url: "https://example.com/image.jpg",
                mediaType: .image,
                hdurl: nil
            )
            
            // Then
            XCTAssertEqual(apod1, apod2)
        }
}
