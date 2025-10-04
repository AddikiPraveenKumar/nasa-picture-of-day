//
//  APODErrorBanner.swift
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
        HStack {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(.orange)
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Network Error - Showing Cached Data")
                    .font(.caption)
                    .fontWeight(.semibold)
                
                Text(errorMessage)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Button(action: retryAction) {
                Text("Retry")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.orange)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
        }
        .padding()
        .background(
            Color.orange.opacity(colorScheme == .dark ? 0.15 : 0.1)
        )
        .cornerRadius(12)
        .padding(.horizontal)
        .padding(.top)
    }
}

#Preview {
    APODErrorBanner(
        errorMessage: "Unable to connect to NASA servers",
        retryAction: { print("Retry") }
    )
}
