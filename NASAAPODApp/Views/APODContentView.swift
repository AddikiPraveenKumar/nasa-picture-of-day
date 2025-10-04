import SwiftUI
struct APODContentView: View {
    @ObservedObject var viewModel: APODViewModel
    var showDateBadge: Bool = false
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ZStack {
            if viewModel.isLoading && viewModel.currentAPOD == nil {
                // Only show full loading state when no data exists
                loadingView
            } else if let apod = viewModel.currentAPOD {
                contentView(for: apod)
            } else if let error = viewModel.errorMessage {
                errorView(message: error)
            } else {
                emptyStateView
            }
        }
    }
    
    private var loadingView: some View {
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
    
    private func contentView(for apod: APOD) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Error banner if using cached data
                if let error = viewModel.errorMessage {
                    HStack {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.orange)
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Network Error - Showing Cached Data")
                                .font(.caption)
                                .fontWeight(.semibold)
                            Text(error)
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        Button(action: {
                            Task {
                                await viewModel.loadTodayAPOD()
                            }
                        }) {
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
                        colorScheme == .dark
                            ? Color.orange.opacity(0.15)
                            : Color.orange.opacity(0.1)
                    )
                    .cornerRadius(12)
                    .padding(.horizontal)
                    .padding(.top)
                }
                
                if showDateBadge {
                    HStack {
                        Label(apod.date, systemImage: "calendar")
                            .font(.caption)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.accentColor.opacity(colorScheme == .dark ? 0.2 : 0.1))
                            .foregroundColor(.accentColor)
                            .cornerRadius(8)
                        Spacer()
                    }
                    .padding(.horizontal)
                    .padding(.top, viewModel.errorMessage == nil ? 16 : 0)
                }
                
                Text(apod.title)
                    .font(showDateBadge ? .title2 : .title)
                    .fontWeight(.bold)
                    .padding(.horizontal)
                
                if !showDateBadge {
                    Text(apod.date)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .padding(.horizontal)
                }
                
                mediaView(for: apod)
                
                VStack(alignment: .leading, spacing: 12) {
                    Label("Explanation", systemImage: "text.alignleft")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text(apod.explanation)
                        .font(.body)
                        .foregroundColor(.secondary)
                        .lineSpacing(4)
                }
                .padding()
                .background(
                    colorScheme == .dark
                        ? Color.secondary.opacity(0.15)
                        : Color.secondary.opacity(0.1)
                )
                .cornerRadius(12)
                .padding(.horizontal)
                
            }
            .padding(.vertical)
        }
    }
    
    private func mediaView(for apod: APOD) -> some View {
        Group {
            if apod.isVideo, let videoURL = apod.videoURL {
                VideoPlayerView(url: videoURL)
                    .frame(height: showDateBadge ? 250 : 300)
                    .cornerRadius(12)
                    .padding(.horizontal)
            } else {
                ZStack {
                    if let image = viewModel.cachedImage {
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .cornerRadius(12)
                    } else if viewModel.isLoadingImage {
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
                            .frame(height: showDateBadge ? 250 : 300)
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
                    } else {
                        // No image available or failed to load
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
                            .frame(height: showDateBadge ? 250 : 300)
                            .overlay(
                                VStack(spacing: 12) {
                                    Image(systemName: "photo.fill.on.rectangle.fill")
                                        .font(.system(size: 50))
                                        .foregroundColor(colorScheme == .dark ? .gray : .gray)
                                    Text(viewModel.errorMessage != nil ? "Image from cache unavailable" : "No image available")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                        .multilineTextAlignment(.center)
                                        .padding(.horizontal)
                                }
                            )
                            .cornerRadius(12)
                    }
                }
                .padding(.horizontal)
            }
        }
    }
    
    private func errorView(message: String) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 50))
                .foregroundColor(.orange)
            
            Text("Unable to Load APOD")
                .font(.title2)
                .fontWeight(.bold)
            
            Text(message)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Text("No cached data available")
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.top, 4)
            
            Button(action: {
                Task {
                    await viewModel.loadTodayAPOD()
                }
            }) {
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
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "calendar.badge.exclamationmark")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            Text("Select a date and load APOD")
                .font(.body)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
