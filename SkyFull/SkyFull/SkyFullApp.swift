import SwiftUI
import SwiftData

@main
struct WeatherCastApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [CachedWeather.self, SavedLocationModel.self])
    }
}
