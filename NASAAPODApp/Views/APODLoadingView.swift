//
//  APODLoadingView.swift
//  NASAAPODApp
//
//  Created by Praveen UK on 04/10/2025.
//

import SwiftUI

struct APODLoadingView: View {
    var body: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.2)
            
            Text("Loading Astronomy Picture...")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Text("Fetching data from NASA")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    APODLoadingView()
}
