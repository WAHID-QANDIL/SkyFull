import Foundation
import SwiftUI
import SwiftData

@MainActor
final class WeatherViewModel: ObservableObject {


    @Published var weatherData: WeatherResponse?
    @Published var isLoading   = false
    @Published var error: String?

    @Published var savedLocations: [SavedLocationModel] = []
    @Published var searchResults:  [SearchResult]       = []
    @Published var isSearching = false


    private let repository: WeatherRepositoryProtocol
    private var searchTask: Task<Void, Never>?

    nonisolated init(repository: WeatherRepositoryProtocol) {
        self.repository = repository
    }

    var isMorning: Bool {
        let h = Calendar.current.component(.hour, from: Date())
        return h >= 5 && h < 18
    }

    var textColor: Color { isMorning ? .black : .white }
    
    func loadCurrentLocation(context: ModelContext) async {
        await load(query: "Cairo,Egypt", context: context)
    }

    func load(query: String, context: ModelContext) async {
        isLoading = true
        error     = nil
        do {
            weatherData = try await repository.fetchForecast(query: query, context: context)
        } catch {
            self.error = error.localizedDescription
        }
        isLoading = false
    }

    func search(query: String) {
        let q = query.trimmingCharacters(in: .whitespaces)
        guard !q.isEmpty else { searchResults = []; return }

        searchTask?.cancel()
        searchTask = Task {
            try? await Task.sleep(for: .milliseconds(400))
            guard !Task.isCancelled else { return }
            isSearching = true
            do   { searchResults = try await repository.searchLocations(query: q) }
            catch { searchResults = [] }
            isSearching = false
        }
    }

    func refreshSavedLocations(context: ModelContext) {
        savedLocations = (try? repository.fetchSavedLocations(context: context)) ?? []
    }

    func addLocation(_ result: SearchResult, context: ModelContext) {
        try? repository.addLocation(result, context: context)
        refreshSavedLocations(context: context)
    }

    func removeLocation(_ location: SavedLocationModel, context: ModelContext) {
        try? repository.removeLocation(location, context: context)
        refreshSavedLocations(context: context)
    }

    func tempStr(_ c: Double) -> String { "\(Int(c.rounded()))°" }

    func pressureStr(_ mb: Double) -> String {
        let fmt = NumberFormatter()
        fmt.numberStyle       = .decimal
        fmt.groupingSeparator = ","
        return fmt.string(from: NSNumber(value: Int(mb.rounded()))) ?? "\(Int(mb))"
    }
}
