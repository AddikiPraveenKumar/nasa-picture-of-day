//
//  APODCacheService.swift
//  NASAAPODApp
//
//  Created by Praveen UK on 01/10/2025.
//

import Foundation
class APODCacheService: APODCacheProtocol {
    private let userDefaults: UserDefaults
    private let key = "cachedAPOD"
    
    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }
    
    func save(_ apod: APOD) throws {
        let encoder = JSONEncoder()
        let data = try encoder.encode(apod)
        print("userdeafaults saved\(data)")
        userDefaults.set(data, forKey: key)
    }
    
    func load() -> APOD? {
        guard let data = userDefaults.data(forKey: key) else {
            return nil
        }
        return try? JSONDecoder().decode(APOD.self, from: data)
    }
    
    func clear() {
        userDefaults.removeObject(forKey: key)
    }
}
