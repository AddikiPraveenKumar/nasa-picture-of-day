//
//  APODMediaView.swift
//  NASAAPODApp
//
//  Created by Praveen UK on 04/10/2025.
//

import SwiftUI

struct APODMediaView: View {
    let apod: APOD
    let cachedImage: UIImage?
    let isLoadingImage: Bool
    let hasError: Bool
    let height: CGFloat
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        Group {
            if apod.isVideo, let videoURL = apod.videoURL {
                VideoPlayerView(url: videoURL)
                    .frame(height: height)
                    .cornerRadius(12)
                    .padding(.horizontal)
            } else {
                ZStack {
                    if let image = cachedImage {
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .cornerRadius(12)
                    } else if isLoadingImage {
                        imageLoadingPlaceholder
                    } else {
                        imageUnavailablePlaceholder
                    }
                }
                .padding(.horizontal)
            }
        }
    }
    
    private var imageLoadingPlaceholder: some View {
        Rectangle()
            .fill(
                LinearGradient(
                    colors: colorScheme == .dark
                        ? [Color(white: 0.15), Color(white: 0.2)]
                        : [Color.secondary.opacity(0.1), Color.secondary.opacity(0.2)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .frame(height: height)
            .overlay(
                VStack(spacing: 12) {
                    ProgressView()
                    
                    Text("Downloading image...")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("This may take a moment")
                        .font(.caption2)
                        .foregroundColor(.secondary.opacity(0.7))
                }
            )
            .cornerRadius(12)
    }
    
    private var imageUnavailablePlaceholder: some View {
        Rectangle()
            .fill(
                LinearGradient(
                    colors: colorScheme == .dark
                        ? [Color(white: 0.15), Color(white: 0.25)]
                        : [Color.gray.opacity(0.2), Color.gray.opacity(0.3)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .frame(height: height)
            .overlay(
                VStack(spacing: 12) {
                    Image(systemName: "photo.fill.on.rectangle.fill")
                        .font(.system(size: 50))
                        .foregroundColor(.gray)
                    
                    Text(hasError ? "Image from cache unavailable" : "No image available")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
            )
            .cornerRadius(12)
    }
}

#Preview {
    VStack {
        APODMediaView(
            apod: APOD(
                date: "2024-10-05",
                title: "Test",
                explanation: "Test",
                url: "https://example.com/image.jpg",
                mediaType: .image,
                hdurl: nil
            ),
            cachedImage: nil,
            isLoadingImage: true,
            hasError: false,
            height: 250
        )
    }
}
