//
//  Date+Extension.swift
//  NASAAPODApp
//
//  Created by Praveen UK on 04/10/2025.
//

import Foundation

extension Date {
    private static let apodFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        return formatter
    }()
    
    func toString() -> String {
        Self.apodFormatter.string(from: self)
    }
}
