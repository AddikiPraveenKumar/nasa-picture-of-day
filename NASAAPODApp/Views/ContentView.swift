//
//  ContentView.swift
//  NASAAPODApp
//
//  Created by Praveen UK on 01/10/2025.
//

import SwiftUI

//
//  ContentView.swift
//  NASAAPODApp
//
//  Created by Praveen UK on 01/10/2025.
//

import SwiftUI

struct ContentView: View {
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
    ContentView()
}

#Preview("Large Text") {
    ContentView()
        .environment(\.sizeCategory, .accessibilityLarge)
}

#Preview("Extra Extra Large Text") {
    ContentView()
        .environment(\.sizeCategory, .accessibilityExtraExtraLarge)
}

#Preview("Extra Extra Extra Large Text") {
    ContentView()
        .environment(\.sizeCategory, .accessibilityExtraExtraExtraLarge)
}
