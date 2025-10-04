//
//  ContentView.swift
//  NASAAPODApp
//
//  Created by Praveen UK on 01/10/2025.
//

import SwiftUI

struct HomeView: View {
    var body: some View {
        TabView {
            APODDetailView()
                .tabItem {
                    Label("Today", systemImage: "star.fill")
                }
                .accessibilityLabel("Today's astronomy picture")
            
            DatePickerView()
                .tabItem {
                    Label("Browse", systemImage: "calendar")
                }
                .accessibilityLabel("Browse astronomy pictures by date")
        }
    }
}

#Preview {
    HomeView()
}

#Preview("Large Text") {
    HomeView()
        .environment(\.sizeCategory, .accessibilityLarge)
}

#Preview("Extra Extra Large Text") {
    HomeView()
        .environment(\.sizeCategory, .accessibilityExtraExtraLarge)
}

#Preview("Extra Extra Extra Large Text") {
    HomeView()
        .environment(\.sizeCategory, .accessibilityExtraExtraExtraLarge)
}
