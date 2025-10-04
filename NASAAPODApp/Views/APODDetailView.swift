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
                .onAppear {
                    // Only load if we don't have data already
                        Task {
                            await viewModel.loadTodayAPOD()
                        }
                }
        }
        .navigationViewStyle(.stack)
    }
}

#Preview {
    APODDetailView()
}
