import SwiftUI

// MARK: - WeatherView  (Screen 1)
//
// FIX: replaced ZStack+ignoresSafeArea with .background { } modifier.
// The background now correctly sits BEHIND the content without fighting
// the NavigationStack safe-area layout.

struct WeatherView: View {
    @ObservedObject var viewModel: WeatherViewModel

    var body: some View {
        Group {
            if viewModel.isLoading && viewModel.weatherData == nil {
                loadingView
            } else if let data = viewModel.weatherData {
                scrollContent(data: data)
            } else if let err = viewModel.error {
                errorView(message: err)
            }
        }
        // Background fills edge-to-edge (behind nav bar too) via ignoresSafeArea
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background {
            WeatherBackground(isMorning: viewModel.isMorning)
                .ignoresSafeArea()
        }
        // Register destination once here; works for both main and detail screens
        .navigationDestination(for: ForecastDay.self) { day in
            HourlyForecastView(
                day: day,
                isMorning: viewModel.isMorning,
                textColor: viewModel.textColor
            )
        }
    }

    // MARK: - Sub-views

    private var loadingView: some View {
        ProgressView()
            .progressViewStyle(.circular)
            .tint(viewModel.textColor)
            .scaleEffect(1.6)
    }

    private func errorView(message: String) -> some View {
        VStack(spacing: 14) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 44))
            Text(message)
                .multilineTextAlignment(.center)
                .font(.callout)
        }
        .foregroundStyle(viewModel.textColor)
        .padding(32)
    }

    private func scrollContent(data: WeatherResponse) -> some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .center, spacing: 24) {

                // ── Top: location / temp / condition ──────────────────
                TopSectionView(data: data, textColor: viewModel.textColor)
                    .padding(.top, 20)

                // ── Middle: 3-Day Forecast ─────────────────────────
                ForecastSectionView(
                    forecastDays: data.forecast.forecastday,
                    textColor: viewModel.textColor,
                    isMorning: viewModel.isMorning
                )
                .padding(.horizontal, 16)

                // ── Bottom: detail grid ────────────────────────────
                BottomSectionView(
                    current: data.current,
                    textColor: viewModel.textColor,
                    isMorning: viewModel.isMorning,
                    pressureStr: viewModel.pressureStr(data.current.pressureMb)
                )
                .padding(.horizontal, 16)
                .padding(.bottom, 40)
            }
            // Explicit max width forces the VStack to fill the scroll area
            // so children stretch correctly on all device sizes
            .frame(maxWidth: .infinity)
        }
        // Subtle spinner overlay while background-refreshing cached data
        .overlay(alignment: .top) {
            if viewModel.isLoading {
                ProgressView()
                    .tint(viewModel.textColor)
                    .padding(.top, 8)
            }
        }
    }
}
