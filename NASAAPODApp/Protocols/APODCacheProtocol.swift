//
//  APODCacheProtocol.swift
//  NASAAPODApp
//
//  Created by Praveen UK on 01/10/2025.
//

import Foundation

protocol APODCacheProtocol {
    func save(_ apod: APOD) throws
    func load() -> APOD?
    func clear()
}

