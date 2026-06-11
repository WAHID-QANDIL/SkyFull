import SwiftUI

// MARK: - ContentView

struct ContentView: View {
    @StateObject private var viewModel = DIContainer.shared.resolve(WeatherViewModel.self)
    @Environment(\.modelContext) private var context

    @State private var showLocations = false

    var body: some View {
        NavigationStack {
            WeatherView(viewModel: viewModel)
                // No .ignoresSafeArea() here — WeatherView's .background handles
                // the edge-to-edge fill while ScrollView content stays in safe area
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            showLocations = true
                        } label: {
                            Image(systemName: "magnifyingglass")
                                .font(.title3.weight(.medium))
                                .foregroundStyle(viewModel.textColor)
                        }
                    }
                }
                .toolbarBackground(.hidden, for: .navigationBar)
        }
        .sheet(isPresented: $showLocations) {
            LocationSearchView(viewModel: viewModel)
        }
        .task {
            await viewModel.loadCurrentLocation(context: context)
        }
        .onAppear {
            viewModel.refreshSavedLocations(context: context)
        }
    }
}
