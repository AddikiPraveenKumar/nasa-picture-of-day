//
//  ImageCacheProtocol.swift
//  NASAAPODApp
//
//  Created by Praveen UK on 01/10/2025.
//

import UIKit

protocol ImageCacheProtocol {
    func save(_ image: UIImage, forKey key: String)
    func load(forKey key: String) -> UIImage?
    func clear()
}
