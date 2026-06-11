import SwiftUI

// MARK: - HourlyForecastView  (Screen 2)

struct HourlyForecastView: View {
    let day: ForecastDay
    let isMorning: Bool
    let textColor: Color

    var body: some View {
        ZStack {
            WeatherBackground(isMorning: isMorning)
                .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    ForEach(day.relevantHours) { hour in
                        HourlyRow(hour: hour, textColor: textColor)
                        Divider()
                            .background(textColor.opacity(0.2))
                            .padding(.horizontal, 24)
                    }
                }
                .padding(.top, 12)
                .padding(.bottom, 40)
            }
        }
        .navigationTitle(day.dayLabel)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
        .toolbarColorScheme(isMorning ? .light : .dark, for: .navigationBar)
    }
}

// MARK: - HourlyRow

private struct HourlyRow: View {
    let hour: HourForecast
    let textColor: Color

    var body: some View {
        HStack {
            // Time label
            Text(hour.displayTime)
                .font(.title3.weight(.medium))
                .foregroundColor(textColor)
                .frame(width: 76, alignment: .leading)

            Spacer()

            // Condition icon
            AsyncImage(url: hour.condition.iconURL) { phase in
                if case .success(let img) = phase {
                    img.resizable().scaledToFit()
                } else {
                    Image(systemName: "cloud")
                        .foregroundColor(textColor)
                }
            }
            .frame(width: 44, height: 44)

            Spacer()

            // Temperature
            Text("\(Int(hour.tempC.rounded()))°")
                .font(.title3)
                .foregroundColor(textColor)
                .frame(width: 52, alignment: .trailing)
        }
        .padding(.horizontal, 28)
        .padding(.vertical, 18)
    }
}
