//
//  APODContentView.swift
//  NASAAPODApp
//

import SwiftUI

struct APODContentView: View {
    @ObservedObject var viewModel: APODViewModel
    var showDateBadge: Bool = false
    
    var body: some View {
        ZStack {
            if viewModel.isLoading && viewModel.currentAPOD == nil {
                APODLoadingView()
            } else if let apod = viewModel.currentAPOD {
                contentView(for: apod)
            } else if let error = viewModel.errorMessage {
                APODErrorStateView(
                    errorMessage: error,
                    retryAction: {
                        Task {
                            await viewModel.loadTodayAPOD()
                        }
                    }
                )
            } else {
                APODEmptyStateView()
            }
        }
    }
    
    private func contentView(for apod: APOD) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Error banner if using cached data
                if let error = viewModel.errorMessage {
                    APODErrorBanner(
                        errorMessage: error,
                        retryAction: {
                            Task {
                                await viewModel.loadTodayAPOD()
                            }
                        }
                    )
                }
                
                // Date badge
                if showDateBadge {
                    APODDateBadge(date: apod.date)
                        .padding(.top, viewModel.errorMessage == nil ? 16 : 0)
                }
                
                // Title
                Text(apod.title)
                    .font(showDateBadge ? .title2 : .title)
                    .fontWeight(.bold)
                    .padding(.horizontal)
                
                // Date for non-badge view
                if !showDateBadge {
                    Text(apod.date)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .padding(.horizontal)
                }
                
                // Media (image or video)
                APODMediaView(
                    apod: apod,
                    cachedImage: viewModel.cachedImage,
                    isLoadingImage: viewModel.isLoadingImage,
                    hasError: viewModel.errorMessage != nil,
                    height: showDateBadge ? 250 : 300
                )
                
                // Explanation
                APODExplanationSection(explanation: apod.explanation)
            }
            .padding(.vertical)
        }
    }
}
