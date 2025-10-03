//
//  APODDetailView.swift
//  NASAAPODApp
//
//  Created by Praveen UK on 01/10/2025.
//

import SwiftUI
struct APODDetailView: View {
    @StateObject private var viewModel = APODViewModel()
    
    var body: some View {
        NavigationView {
            APODContentView(viewModel: viewModel, showDateBadge: false)
                .navigationTitle("Astronomy Picture")
                .navigationBarTitleDisplayMode(.inline)
                .animation(.easeInOut(duration: 0.2), value: viewModel.currentAPOD)
                .animation(.easeInOut(duration: 0.2), value: viewModel.isLoading)
                .onAppear {
                    // Only load if we don't have data already
                    if viewModel.currentAPOD == nil && !viewModel.isLoading {
                        Task {
                            await viewModel.loadTodayAPOD()
                        }
                    }
                }
        }
        .navigationViewStyle(.stack)
    }
}

#Preview {
    APODDetailView()
}
