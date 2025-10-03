//
//  APOD.swift
//  NASAAPODApp
//
//  Created by Praveen UK on 01/10/2025.
//

import Foundation
struct APOD: Codable, Equatable {
    let date: String
    let title: String
    let explanation: String
    let url: String
    let mediaType: String
    let hdurl: String?
    
    enum CodingKeys: String, CodingKey {
        case date, title, explanation, url
        case mediaType = "media_type"
        case hdurl
    }
    
    var isVideo: Bool {
        mediaType == "video"
    }
    
    var imageURL: URL? {
        URL(string: hdurl ?? url)
    }
    
    var videoURL: URL? {
        isVideo ? URL(string: url) : nil
    }
}
