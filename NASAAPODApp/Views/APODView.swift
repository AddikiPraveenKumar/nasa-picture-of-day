//
//  APODView.swift
//  NASAAPODApp
//
//  Created by Praveen UK on 04/10/2025.
//

import SwiftUI

struct APODView: View {
    @StateObject private var viewModel = APODViewModel()
    @State private var selectedDate = Date()
    @State private var showDatePicker = false
    @Environment(\.dynamicTypeSize) var dynamicTypeSize
    
    var body: some View {
        NavigationView {
            ZStack {
                if viewModel.isLoading && viewModel.currentAPOD == nil {
                    APODLoadingView()
                } else if let apod = viewModel.currentAPOD {
                    contentView(for: apod)
                } else if let error = viewModel.errorMessage {
                    APODErrorStateView(
                        errorMessage: error,
                        retryAction: { Task { await viewModel.loadTodayAPOD() } }
                    )
                }
            }
            .navigationTitle("APOD")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showDatePicker.toggle()
                    } label: {
                        Image(systemName: "calendar")
                            .imageScale(.large)
                    }
                    .accessibilityLabel("Select date")
                    .accessibilityHint("Opens date picker to choose astronomy picture date")
                }
            }
            .sheet(isPresented: $showDatePicker) {
                APODDatePickerSheet(
                    selectedDate: $selectedDate,
                    onLoad: { Task { await viewModel.loadAPOD(for: selectedDate) } }
                )
            }
            .onAppear {
                if viewModel.currentAPOD == nil && !viewModel.isLoading {
                    Task { await viewModel.loadTodayAPOD() }
                }
            }
        }
        .navigationViewStyle(.stack)
    }
    
    private func contentView(for apod: APOD) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: scaledSpacing(16)) {
                if let error = viewModel.errorMessage {
                    APODErrorBanner(
                        errorMessage: error,
                        retryAction: { Task { await viewModel.loadAPOD(for: selectedDate) } }
                    )
                }
                
                APODDateBadge(date: apod.date)
                    .padding(.top, viewModel.errorMessage == nil ? scaledSpacing(16) : 0)
                
                Text(apod.title)
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.horizontal)
                    .fixedSize(horizontal: false, vertical: true)
                    .accessibilityAddTraits(.isHeader)
                
                APODMediaView(
                    apod: apod,
                    cachedImage: viewModel.cachedImage,
                    isLoadingImage: viewModel.isLoadingImage
                )
                
                APODExplanationSection(explanation: apod.explanation)
            }
            .padding(.vertical)
        }
    }
    
    private func scaledSpacing(_ base: CGFloat) -> CGFloat {
        dynamicTypeSize.isAccessibilitySize ? base * 1.5 : base
    }
}

#Preview {
    APODView()
}

#Preview("Accessibility Large") {
    APODView()
        .environment(\.dynamicTypeSize, .accessibility3)
}
