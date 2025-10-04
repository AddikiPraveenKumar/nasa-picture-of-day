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
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 50))
                .foregroundColor(.orange)
            
            Text("Unable to Load APOD")
                .font(.title2)
                .fontWeight(.bold)
            
            Text(errorMessage)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Text("No cached data available")
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.top, 4)
            
            Button(action: retryAction) {
                Label("Try Again", systemImage: "arrow.clockwise")
                    .fontWeight(.semibold)
                    .padding()
                    .background(Color.accentColor)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    APODErrorStateView(
        errorMessage: "Network connection failed",
        retryAction: { print("Retry") }
    )
}
