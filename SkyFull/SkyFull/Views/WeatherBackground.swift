import SwiftUI

struct WeatherBackground: View {
    let isMorning: Bool

    var body: some View {
        ZStack {
            gradientLayer
            Image(isMorning ? "morningBG" : "eveningBG")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
        }
        .ignoresSafeArea()
    }

    @ViewBuilder
    private var gradientLayer: some View {
        if isMorning {
            LinearGradient(
                gradient: Gradient(stops: [
                    .init(color: Color(red: 0.54, green: 0.82, blue: 0.97), location: 0.00),
                    .init(color: Color(red: 0.72, green: 0.89, blue: 0.98), location: 0.45),
                    .init(color: Color(red: 0.99, green: 0.88, blue: 0.65), location: 1.00)
                ]),
                startPoint: .top, endPoint: .bottom
            )
        } else {
            LinearGradient(
                gradient: Gradient(stops: [
                    .init(color: Color(red: 0.07, green: 0.07, blue: 0.22), location: 0.00),
                    .init(color: Color(red: 0.14, green: 0.11, blue: 0.38), location: 0.50),
                    .init(color: Color(red: 0.28, green: 0.09, blue: 0.33), location: 1.00)
                ]),
                startPoint: .top, endPoint: .bottom
            )
        }
    }
}
