import Foundation


struct WeatherResponse: Codable {
    let location: WeatherLocation
    let current: CurrentWeather
    let forecast: WeatherForecast
}

struct WeatherLocation: Codable {
    let name: String
    let region: String
    let country: String
    let lat: Double
    let lon: Double
}


struct CurrentWeather: Codable {
    let tempC: Double
    let feelslikeC: Double
    let humidity: Int
    let visKm: Double
    let pressureMb: Double
    let condition: WeatherCondition
    
    enum CodingKeys: String, CodingKey {
        case tempC      = "temp_c"
        case feelslikeC = "feelslike_c"
        case humidity
        case visKm      = "vis_km"
        case pressureMb = "pressure_mb"
        case condition
    }
}

struct WeatherCondition: Codable {
    let text: String
    let icon: String
    let code: Int

    var iconURL: URL? {
        let secure = icon.hasPrefix("//") ? "https:" + icon : icon
        return URL(string: secure)
    }
}


struct WeatherForecast: Codable {
    let forecastday: [ForecastDay]
}


struct ForecastDay: Codable, Identifiable, Hashable {
    static func == (lhs: ForecastDay, rhs: ForecastDay) -> Bool { lhs.date == rhs.date }
       func hash(into hasher: inout Hasher) { hasher.combine(date) }
    
    var id: String { date }
    let date: String
    let day: DayForecast
    let hour: [HourForecast]

    /// "Today", "Tomorrow", or short weekday (e.g. "Wed")
    var dayLabel: String {
        let df = DateFormatter()
        df.locale = Locale(identifier: "en_US_POSIX")
        df.dateFormat = "yyyy-MM-dd"
        guard let d = df.date(from: date) else { return date }
        let cal = Calendar.current
        if cal.isDateInToday(d)    { return "Today" }
        if cal.isDateInTomorrow(d) { return "Tomorrow" }
        let wf = DateFormatter()
        wf.dateFormat = "EEE"
        return wf.string(from: d)
    }

    /// Today → hours from now onward. Other days → all 24 hours.
    var relevantHours: [HourForecast] {
        let df = DateFormatter()
        df.locale = Locale(identifier: "en_US_POSIX")
        df.dateFormat = "yyyy-MM-dd"
        guard let forecastDate = df.date(from: date) else { return hour }

        if Calendar.current.isDateInToday(forecastDate) {
            let nowHour = Calendar.current.component(.hour, from: Date())
            return hour.filter { h in
                guard let hDate = h.hourDate else { return true }
                return Calendar.current.component(.hour, from: hDate) >= nowHour
            }
        }
        return hour
    }
}


struct DayForecast: Codable {
    let maxtempC: Double
    let mintempC: Double
    let condition: WeatherCondition

    enum CodingKeys: String, CodingKey {
        case maxtempC = "maxtemp_c"
        case mintempC = "mintemp_c"
        case condition
    }
}


struct HourForecast: Codable, Identifiable {
    var id: String { time }
    let time: String
    let tempC: Double
    let condition: WeatherCondition

    enum CodingKeys: String, CodingKey {
        case time
        case tempC = "temp_c"
        case condition
    }

    var hourDate: Date? {
        let df = DateFormatter()
        df.locale = Locale(identifier: "en_US_POSIX")
        df.dateFormat = "yyyy-MM-dd HH:mm"
        return df.date(from: time)
    }

    /// "Now" for the current hour today, otherwise "3PM", "4PM", etc.
    var displayTime: String {
        guard let d = hourDate else { return time }
        let cal = Calendar.current
        if cal.isDateInToday(d),
           cal.component(.hour, from: d) == cal.component(.hour, from: Date()) {
            return "Now"
        }
        let fmt = DateFormatter()
        fmt.dateFormat = "ha"
        return fmt.string(from: d).uppercased()
    }
}

struct SearchResult: Codable, Identifiable {
    let id: Int
    let name: String
    let region: String
    let country: String
    let lat: Double
    let lon: Double

    var displayName: String {
        [name, region, country].filter { !$0.isEmpty }.joined(separator: ", ")
    }
}
