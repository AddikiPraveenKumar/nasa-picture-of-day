//
//  APOD.swift
//  NASAAPODApp
//
//  Created by Praveen UK on 01/10/2025.
//

import Foundation

struct APOD: Codable, Equatable, Identifiable {
    let id: String               // ✅ Make it a parameter
    let date: String
    let title: String
    let explanation: String
    let url: String
    let mediaType: MediaType
    let hdurl: String?
    
    // Custom initializer for tests
    init(
        id: String = UUID().uuidString,  // ✅ Default value
        date: String,
        title: String,
        explanation: String,
        url: String,
        mediaType: MediaType,
        hdurl: String? = nil
    ) {
        self.id = id
        self.date = date
        self.title = title
        self.explanation = explanation
        self.url = url
        self.mediaType = mediaType
        self.hdurl = hdurl
    }
    
    enum CodingKeys: String, CodingKey {
        case date, title, explanation, url
        case mediaType = "media_type"
        case hdurl
    }
    
    // Custom decoder to generate ID
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = UUID().uuidString  // Generate ID when decoding
        self.date = try container.decode(String.self, forKey: .date)
        self.title = try container.decode(String.self, forKey: .title)
        self.explanation = try container.decode(String.self, forKey: .explanation)
        self.url = try container.decode(String.self, forKey: .url)
        self.mediaType = try container.decode(MediaType.self, forKey: .mediaType)
        self.hdurl = try container.decodeIfPresent(String.self, forKey: .hdurl)
    }
    
    var isVideo: Bool {
        mediaType == .video
    }
    
    var imageURL: URL? {
        URL(string: hdurl ?? url)
    }
    
    var videoURL: URL? {
        isVideo ? URL(string: url) : nil
    }
}
