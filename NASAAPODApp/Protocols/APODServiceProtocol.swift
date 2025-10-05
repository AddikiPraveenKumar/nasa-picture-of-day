//
//  APODServiceProtocol.swift
//  NASAAPODApp
//
//  Created by Praveen UK on 01/10/2025.
//

import Foundation

protocol APODServiceProtocol {
    func fetchAPOD(for date: Date?) async throws -> APOD
}
