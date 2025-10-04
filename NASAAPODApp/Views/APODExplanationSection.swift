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
    @Environment(\.dynamicTypeSize) var dynamicTypeSize
    
    var body: some View {
        VStack(alignment: .leading, spacing: scaledSpacing(12)) {
            Label("Explanation", systemImage: "text.alignleft")
                .font(.headline)
                .accessibilityAddTraits(.isHeader)
            
            Text(explanation)
                .font(.body)
                .foregroundColor(.secondary)
                .lineSpacing(scaledSpacing(4))
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding()
        .background(
            Color.secondary.opacity(colorScheme == .dark ? 0.15 : 0.1)
        )
        .cornerRadius(12)
        .padding(.horizontal)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Explanation: \(explanation)")
    }
    
    private func scaledSpacing(_ base: CGFloat) -> CGFloat {
        dynamicTypeSize.isAccessibilitySize ? base * 1.5 : base
    }
}

#Preview {
    APODExplanationSection(
        explanation: "This is a sample explanation of an astronomy picture of the day. It contains detailed information about the celestial object or phenomenon shown in the image."
    )
}
