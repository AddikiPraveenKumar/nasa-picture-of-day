//
//  APODLoadingView.swift
//  NASAAPODApp
//
//  Created by Praveen UK on 04/10/2025.
//

import SwiftUI

struct APODLoadingView: View {
    @Environment(\.dynamicTypeSize) var dynamicTypeSize
    
    var body: some View {
        VStack(spacing: scaledSpacing(16)) {
            ProgressView()
                .scaleEffect(dynamicTypeSize.isAccessibilitySize ? 1.5 : 1.2)
            
            Text("Loading...")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Loading astronomy picture")
    }
    
    private func scaledSpacing(_ base: CGFloat) -> CGFloat {
        dynamicTypeSize.isAccessibilitySize ? base * 1.5 : base
    }
}

extension DynamicTypeSize {
    var isAccessibilitySize: Bool {
        self >= .accessibility1
    }
}
