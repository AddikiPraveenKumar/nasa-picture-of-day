import SwiftUI

struct DatePickerView: View {
    @StateObject private var viewModel = APODViewModel()
    @State private var selectedDate = Date()
    @State private var showDatePicker = false
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                VStack(spacing: 16) {
                    Text("Select a Date")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Button(action: {
                        showDatePicker.toggle()
                    }) {
                        HStack {
                            Image(systemName: "calendar")
                                .font(.title2)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Selected Date")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text(selectedDate, style: .date)
                                    .font(.headline)
                            }
                            
                            Spacer()
                            
                            Image(systemName: showDatePicker ? "chevron.up" : "chevron.down")
                                .foregroundColor(.secondary)
                        }
                        .padding()
                        .background(
                            colorScheme == .dark
                                ? Color.secondary.opacity(0.15)
                                : Color.secondary.opacity(0.1)
                        )
                        .cornerRadius(12)
                    }
                    .buttonStyle(.plain)
                    
                    if showDatePicker {
                        DatePicker("",
                                  selection: $selectedDate,
                                  in: ...Date(),
                                  displayedComponents: .date)
                            .datePickerStyle(.graphical)
                            .padding(.horizontal)
                            .transition(.move(edge: .top).combined(with: .opacity))
                    }
                    
                    Button(action: loadAPOD) {
                        HStack {
                            if viewModel.isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .scaleEffect(0.8)
                            } else {
                                Image(systemName: "arrow.down.circle.fill")
                                Text("Load APOD")
                                    .fontWeight(.semibold)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(viewModel.isLoading ? Color.gray : Color.accentColor)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                    .disabled(viewModel.isLoading)
                }
                .padding()
                .background(Color(uiColor: .systemBackground))
                
                Divider()
                
                APODContentView(viewModel: viewModel, showDateBadge: true)
            }
            .navigationTitle("Browse APOD")
            .animation(.spring(response: 0.3), value: showDatePicker)
            .animation(.spring(response: 0.3), value: viewModel.currentAPOD)
        }
        .navigationViewStyle(.stack)
    }
    
    private func loadAPOD() {
        showDatePicker = false
        Task {
            await viewModel.loadAPOD(for: selectedDate)
        }
    }
}
