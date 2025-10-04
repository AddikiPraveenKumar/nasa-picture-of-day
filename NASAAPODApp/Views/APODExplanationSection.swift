//
//  APODExplanationSection.swift
//  NASAAPODApp
//
//  Created by Praveen UK on 04/10/2025.
//

import SwiftUI

struct APODExplanationSection: View {
    let explanation: String
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Explanation", systemImage: "text.alignleft")
                .font(.headline)
                .foregroundColor(.primary)
            
            Text(explanation)
                .font(.body)
                .foregroundColor(.secondary)
                .lineSpacing(4)
        }
        .padding()
        .background(
            colorScheme == .dark
                ? Color.secondary.opacity(0.15)
                : Color.secondary.opacity(0.1)
        )
        .cornerRadius(12)
        .padding(.horizontal)
    }
}

#Preview {
    APODExplanationSection(
        explanation: "This is a sample explanation of an astronomy picture of the day. It contains detailed information about the celestial object or phenomenon shown in the image."
    )
}
