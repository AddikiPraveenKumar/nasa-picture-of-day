//
//  APODServiceProtocol.swift
//  NASAAPODApp
//
//  Created by Praveen UK on 01/10/2025.
//

import Foundation

// S - Single Responsibility: Only handles APOD fetching
// I - Interface Segregation: Specific to APOD operations
protocol APODServiceProtocol {
    func fetchAPOD(for date: Date?) async throws -> APOD
}
