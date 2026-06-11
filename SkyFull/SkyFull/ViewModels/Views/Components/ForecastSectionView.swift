import SwiftUI

// MARK: - ForecastSectionView
//
// FIX: replaced NavigationLink { destination } label: { ... } with
// NavigationLink(value: day) — the old form overrides foregroundStyle on
// its label inside a ZStack/ScrollView, making row text invisible.
// NavigationLink(value:) delegates colour entirely to the label view.

struct ForecastSectionView: View {
    let forecastDays: [ForecastDay]
    let textColor: Color
    let isMorning: Bool

    private var cardBG: Color {
        Color.white.opacity(isMorning ? 0.28 : 0.15)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {

            // Section header
            HStack(spacing: 6) {
                Image(systemName: "calendar")
                    .font(.caption)
                Text("3-DAY FORECAST")
                    .font(.caption.weight(.semibold))
            }
            .foregroundStyle(textColor.opacity(0.75))
            .padding(.horizontal, 16)
            .padding(.top, 12)
            .padding(.bottom, 8)

            divider

            ForEach(Array(forecastDays.enumerated()), id: \.element.id) { idx, day in

                // NavigationLink(value:) — label renders exactly as written,
                // no colour override from the link itself.
                NavigationLink(value: day) {
                    ForecastRow(day: day, textColor: textColor)
                }
                .buttonStyle(.plain)            // removes default blue tint

                if idx < forecastDays.count - 1 { divider }
            }

            Spacer(minLength: 10)
        }
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(cardBG)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(textColor.opacity(0.12), lineWidth: 0.5)
                )
        )
    }

    private var divider: some View {
        Rectangle()
            .fill(textColor.opacity(0.2))
            .frame(height: 0.5)
            .padding(.horizontal, 16)
    }
}

// MARK: - ForecastRow

private struct ForecastRow: View {
    let day: ForecastDay
    let textColor: Color

    var body: some View {
        HStack(spacing: 12) {

            Text(day.dayLabel)
                .font(.callout.weight(.medium))
                .foregroundStyle(textColor)          // ← foregroundStyle, not foregroundColor
                .frame(minWidth: 82, alignment: .leading)

            AsyncImage(url: day.day.condition.iconURL) { phase in
                if case .success(let img) = phase {
                    img.resizable().scaledToFit()
                } else {
                    Image(systemName: "cloud")
                        .foregroundStyle(textColor)
                }
            }
            .frame(width: 30, height: 30)

            Spacer()

            Text("\(Int(day.day.mintempC.rounded()))° - \(Int(day.day.maxtempC.rounded()))°")
                .font(.callout)
                .foregroundStyle(textColor)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .contentShape(Rectangle())               // makes full row tappable
    }
}
