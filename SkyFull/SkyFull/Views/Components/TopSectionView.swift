import SwiftUI

struct TopSectionView: View {
    let data: WeatherResponse
    let textColor: Color

    private var today: DayForecast? { data.forecast.forecastday.first?.day }

    var body: some View {
        VStack(alignment: .center, spacing: 4) {

            // City name
            Text(data.location.name)
                .font(.system(size: 34, weight: .semibold))
                .foregroundStyle(textColor)


            Text("\(Int(data.current.tempC.rounded()))°")
                .font(.system(size: 88, weight: .thin))
                .foregroundStyle(textColor)
            
            Text(data.current.condition.text)
                .font(.title3)
                .foregroundStyle(textColor)

            if let t = today {
                Text("H:\(Int(t.maxtempC.rounded()))°  L:\(Int(t.mintempC.rounded()))°")
                    .font(.callout)
                    .foregroundStyle(textColor)
            }

            // Condition icon
            AsyncImage(url: data.current.condition.iconURL) { phase in
                switch phase {
                case .success(let img):
                    img.resizable()
                       .scaledToFit()
                       .frame(width: 90, height: 90)
                case .failure:
                    Image(systemName: "cloud.fill")
                        .font(.system(size: 60))
                        .foregroundStyle(textColor)
                case .empty:
                    ProgressView().frame(width: 90, height: 90)
                @unknown default:
                    EmptyView()
                }
            }
        }
        .frame(maxWidth: .infinity)
        .multilineTextAlignment(.center)
    }
}
