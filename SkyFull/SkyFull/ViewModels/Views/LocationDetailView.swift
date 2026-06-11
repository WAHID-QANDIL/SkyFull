import SwiftUI

// MARK: - LocationDetailView

/// Displays the full weather screen for a saved (non-current) location.
/// Gets its own `WeatherViewModel` instance from the DI container.
struct LocationDetailView: View {
    let location: SavedLocationModel

    @StateObject private var viewModel = DIContainer.shared.resolve(WeatherViewModel.self)
    @Environment(\.modelContext) private var context

    var body: some View {
        ZStack {
            WeatherView(viewModel: viewModel)
                .ignoresSafeArea()
        }
        .toolbar {
            // Show the city name centred in the navigation bar
            ToolbarItem(placement: .principal) {
                Text(location.name)
                    .font(.headline)
                    .foregroundColor(viewModel.textColor)
            }
        }
        .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
        .toolbarColorScheme(viewModel.isMorning ? .light : .dark, for: .navigationBar)
        .task {
            await viewModel.load(query: location.queryString, context: context)
        }
    }
}
