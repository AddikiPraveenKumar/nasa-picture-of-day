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
    @Environment(\.dynamicTypeSize) var dynamicTypeSize
    
    var body: some View {
        ViewThatFits(in: .horizontal) {
            horizontalLayout
            verticalLayout
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
    
    private var horizontalLayout: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(.orange)
                .imageScale(.medium)
                .accessibilityHidden(true)
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Network Error - Showing Cached Data")
                    .font(.caption)
                    .fontWeight(.semibold)
                
                Text(errorMessage)
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .lineLimit(3)
            }
            
            Spacer()
            
            Button("Retry", action: retryAction)
                .font(.caption)
                .fontWeight(.semibold)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.orange)
                .foregroundColor(.white)
                .cornerRadius(8)
        }
    }
    
    private var verticalLayout: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(.orange)
                    .accessibilityHidden(true)
                
                Text("Network Error - Showing Cached Data")
                    .font(.caption)
                    .fontWeight(.semibold)
            }
            
            Text(errorMessage)
                .font(.caption2)
                .foregroundColor(.secondary)
            
            Button("Retry", action: retryAction)
                .font(.caption)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .background(Color.orange)
                .foregroundColor(.white)
                .cornerRadius(8)
        }
    }
}

#Preview {
    APODErrorBanner(
        errorMessage: "Unable to connect to NASA servers",
        retryAction: { }
    )
}
