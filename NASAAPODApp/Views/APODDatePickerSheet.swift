//
//  APODDatePickerSheet.swift
//  NASAAPODApp
//
//  Created by Praveen UK on 04/10/2025.
//

import SwiftUI

struct APODDatePickerSheet: View {
    @Environment(\.dismiss) var dismiss
    @Binding var selectedDate: Date
    let onLoad: () -> Void
    @Environment(\.dynamicTypeSize) var dynamicTypeSize
    
    var body: some View {
        NavigationView {
            VStack(spacing: scaledSpacing(24)) {
                DatePicker(
                    "Select Date",
                    selection: $selectedDate,
                    in: ...Date(),
                    displayedComponents: .date
                )
                .datePickerStyle(.graphical)
                .padding()
                .accessibilityLabel("Date picker")
                .accessibilityHint("Select a date to view astronomy picture")
                
                Button {
                    dismiss()
                    onLoad()
                } label: {
                    Text("Load APOD")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.accentColor)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                .padding(.horizontal)
                .accessibilityLabel("Load astronomy picture for \(selectedDate.formatted(date: .long, time: .omitted))")
                
                Spacer()
            }
            .navigationTitle("Select Date")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .accessibilityLabel("Cancel date selection")
                }
            }
        }
    }
    
    private func scaledSpacing(_ base: CGFloat) -> CGFloat {
        dynamicTypeSize.isAccessibilitySize ? base * 1.5 : base
    }
}

#Preview {
    APODDatePickerSheet(
        selectedDate: .constant(Date()),
        onLoad: { }
    )
}
