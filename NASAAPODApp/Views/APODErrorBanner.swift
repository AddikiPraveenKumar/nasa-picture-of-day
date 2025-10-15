//
//  APODErrorBanner.swift (SIMPLIFIED)
//  NASAAPODApp
//
//  Created by Praveen UK on 04/10/2025.
//

import SwiftUI

struct APODErrorBanner: View {
    let errorMessage: String
    let retryAction: () -> Void
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header with icon
            HStack(spacing: 8) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(.orange)
                    .accessibilityHidden(true)
                
                Text("Network Error - Showing Cached Data")
                    .font(.caption)
                    .fontWeight(.semibold)
            }
            
            // Error message
            Text(errorMessage)
                .font(.caption2)
                .foregroundColor(.secondary)
            
            // Retry button
            Button("Retry", action: retryAction)
                .font(.caption)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .background(Color.orange)
                .foregroundColor(.white)
                .cornerRadius(8)
        }
        .padding()
        .background(Color.orange.opacity(colorScheme == .dark ? 0.15 : 0.1))
        .cornerRadius(12)
        .padding(.horizontal)
        .padding(.top)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Warning: Network error. Showing cached data. \(errorMessage)")
        .accessibilityAction(named: "Retry") {
            retryAction()
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        APODErrorBanner(
            errorMessage: "Unable to connect to NASA servers",
            retryAction: { print("Retry tapped") }
        )
        
        APODErrorBanner(
            errorMessage: "Request timed out. Please check your internet connection.",
            retryAction: { }
        )
    }
    .padding()
}

#Preview("Dark Mode") {
    APODErrorBanner(
        errorMessage: "Unable to connect to NASA servers",
        retryAction: { }
    )
    .preferredColorScheme(.dark)
}
