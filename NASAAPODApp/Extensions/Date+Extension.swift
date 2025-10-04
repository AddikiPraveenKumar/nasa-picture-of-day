//
//  Date+Extension.swift
//  NASAAPODApp
//
//  Created by Praveen UK on 04/10/2025.
//

import Foundation

extension Date {
    func toString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: self)
    }
}
