//
//  APODDateBadge.swift
//  NASAAPODApp
//
//  Created by Praveen UK on 04/10/2025.
//

import SwiftUI

struct APODDateBadge: View {
    let date: String
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        HStack {
            Label(date, systemImage: "calendar")
                .font(.caption)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    Color.accentColor.opacity(colorScheme == .dark ? 0.2 : 0.1)
                )
                .foregroundColor(.accentColor)
                .cornerRadius(8)
            
            Spacer()
        }
        .padding(.horizontal)
    }
}

#Preview {
    APODDateBadge(date: "2024-10-05")
}
