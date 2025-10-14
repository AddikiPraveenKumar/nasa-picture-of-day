//
//  ConfigManager.swift
//  NASAAPODApp
//
//  Created by Praveen UK on 14/10/2025.
//
import Foundation

// MARK: - Configuration Manager
struct ConfigManager {
    static var apiBaseURL: String {
        guard let url = Bundle.main.infoDictionary?["API_BASE_URL"] as? String else {
            fatalError("API_BASE_URL not set in build configuration")
        }
        return url
    }
    
    static var nasaAPIKey: String {
        guard let key = Bundle.main.infoDictionary?["NASA_API_KEY"] as? String else {
            fatalError("NASA_API_KEY not set in build configuration")
        }
        return key
    }
}
