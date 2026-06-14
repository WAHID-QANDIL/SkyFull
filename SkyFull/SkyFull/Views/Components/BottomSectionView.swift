import SwiftUI

struct BottomSectionView: View {
    let current: CurrentWeather
    let textColor: Color
    let isMorning: Bool
    let pressureStr: String

    private var cardBG: Color {
        Color.white.opacity(isMorning ? 0.28 : 0.15)
    }

    var body: some View {
        VStack(spacing: 14) {
            HStack(spacing: 14) {
                DetailCard(
                    title: "VISIBILITY",
                    value: "\(Int(current.visKm)) km",
                    textColor: textColor,
                    background: cardBG
                )
                DetailCard(
                    title: "HUMIDITY",
                    value: "\(current.humidity)%",
                    textColor: textColor,
                    background: cardBG
                )
            }
            HStack(spacing: 14) {
                DetailCard(
                    title: "FEELS LIKE",
                    value: "\(Int(current.feelslikeC.rounded()))°",
                    textColor: textColor,
                    background: cardBG
                )
                DetailCard(
                    title: "PRESSURE",
                    value: pressureStr,
                    textColor: textColor,
                    background: cardBG
                )
            }
        }
    }
}

// MARK: - DetailCard

private struct DetailCard: View {
    let title: String
    let value: String
    let textColor: Color
    let background: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.caption.weight(.semibold))
                .foregroundStyle(textColor.opacity(0.70))

            Text(value)
                .font(.system(size: 28, weight: .light))
                .foregroundStyle(textColor)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(background)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(textColor.opacity(0.12), lineWidth: 0.5)
                )
        )
    }
}
