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
    @Environment(\.dynamicTypeSize) var dynamicTypeSize
    
    var body: some View {
        Group {
            if apod.isVideo, let videoURL = apod.videoURL {
                VideoPlayerView(url: videoURL)
                    .frame(height: mediaHeight)
                    .cornerRadius(12)
                    .accessibilityLabel("Video: \(apod.title)")
                    .accessibilityAddTraits(.startsMediaSession)
            } else {
                imageView
            }
        }
        .padding(.horizontal)
    }
    
    private var imageView: some View {
        ZStack {
            if let image = cachedImage {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .cornerRadius(12)
                    .accessibilityLabel("Image: \(apod.title)")
                    .accessibilityAddTraits(.isImage)
            } else if isLoadingImage {
                placeholderView(
                    icon: nil,
                    text: "Loading image...",
                    showProgress: true
                )
                .accessibilityLabel("Loading image")
            } else {
                placeholderView(
                    icon: "photo",
                    text: "No image available",
                    showProgress: false
                )
                .accessibilityLabel("No image available")
            }
        }
    }
    
    private func placeholderView(
        icon: String?,
        text: String,
        showProgress: Bool
    ) -> some View {
        Rectangle()
            .fill(Color.secondary.opacity(0.1))
            .frame(height: mediaHeight)
            .overlay(
                VStack(spacing: scaledSpacing(8)) {
                    if showProgress {
                        ProgressView()
                            .scaleEffect(dynamicTypeSize.isAccessibilitySize ? 1.3 : 1.0)
                    } else if let icon = icon {
                        Image(systemName: icon)
                            .font(.system(size: dynamicTypeSize.isAccessibilitySize ? 40 : 50))
                            .foregroundColor(.secondary)
                    }
                    
                    Text(text)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
            )
            .cornerRadius(12)
    }
    
    private var mediaHeight: CGFloat {
        dynamicTypeSize.isAccessibilitySize ? 200 : 250
    }
    
    private func scaledSpacing(_ base: CGFloat) -> CGFloat {
        dynamicTypeSize.isAccessibilitySize ? base * 1.5 : base
    }
}

#Preview {
    APODMediaView(
        apod: APOD(
            date: "2024-10-05",
            title: "Test Image",
            explanation: "Test",
            url: "https://example.com/image.jpg",
            mediaType: .image,
            hdurl: nil
        ),
        cachedImage: nil,
        isLoadingImage: true
    )
}
