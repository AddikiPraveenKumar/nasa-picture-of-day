//
//  APODErrorStateView.swift
//  NASAAPODApp
//
//  Created by Praveen UK on 04/10/2025.
//

import SwiftUI

struct APODErrorStateView: View {
    let errorMessage: String
    let retryAction: () -> Void
    @Environment(\.dynamicTypeSize) var dynamicTypeSize
    
    var body: some View {
        VStack(spacing: scaledSpacing(16)) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: dynamicTypeSize.isAccessibilitySize ? 40 : 50))
                .foregroundColor(.orange)
                .accessibilityHidden(true)
            
            Text("Unable to Load APOD")
                .font(.title2)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
                .accessibilityAddTraits(.isHeader)
            
            Text(errorMessage)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
                .fixedSize(horizontal: false, vertical: true)
            
            Text("No cached data available")
                .font(.caption)
                .foregroundColor(.secondary)
            
            Button(action: retryAction) {
                Label("Try Again", systemImage: "arrow.clockwise")
                    .fontWeight(.semibold)
                    .padding()
                    .frame(maxWidth: dynamicTypeSize.isAccessibilitySize ? .infinity : 200)
                    .background(Color.accentColor)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .accessibilityLabel("Try again")
            .accessibilityHint("Attempts to reload astronomy picture")
        }
        .padding()
    }
    
    private func scaledSpacing(_ base: CGFloat) -> CGFloat {
        dynamicTypeSize.isAccessibilitySize ? base * 1.5 : base
    }
}

#Preview {
    APODErrorStateView(
        errorMessage: "Network connection failed",
        retryAction: { }
    )
}
