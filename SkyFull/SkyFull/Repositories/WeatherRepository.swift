import Foundation
import SwiftData

final class WeatherRepository: WeatherRepositoryProtocol {

    private let service: WeatherServiceProtocol

    init(service: WeatherServiceProtocol) {
        self.service = service
    }

    func fetchForecast(query: String, context: ModelContext) async throws -> WeatherResponse {

        let cachedEntry = try? fetchCachedEntry(for: query, context: context)

        if let entry = cachedEntry, !entry.isStale,
           let cached = try? JSONDecoder().decode(WeatherResponse.self, from: entry.jsonData) {
            return cached
        }

        do {
            let response = try await service.fetchForecast(query: query)
            updateCache(query: query, response: response, existing: cachedEntry, context: context)
            return response
        } catch {
            
            if let entry = cachedEntry,
               let stale = try? JSONDecoder().decode(WeatherResponse.self, from: entry.jsonData) {
                return stale
            }
            throw error
        }
    }

    func searchLocations(query: String) async throws -> [SearchResult] {
        try await service.searchLocations(query: query)
    }


    func fetchSavedLocations(context: ModelContext) throws -> [SavedLocationModel] {
        let descriptor = FetchDescriptor<SavedLocationModel>(
            sortBy: [SortDescriptor(\SavedLocationModel.addedAt)]
        )
        return try context.fetch(descriptor)
    }

    func addLocation(_ result: SearchResult, context: ModelContext) throws {
        // Guard against duplicates
        let name    = result.name
        let country = result.country
        let dup = FetchDescriptor<SavedLocationModel>(
            predicate: #Predicate<SavedLocationModel> {
                $0.name == name && $0.country == country
            }
        )
        guard (try context.fetch(dup)).isEmpty else { return }

        context.insert(SavedLocationModel(name: result.name,
                                          country: result.country,
                                          lat: result.lat,
                                          lon: result.lon))
        try context.save()
    }

    func removeLocation(_ location: SavedLocationModel, context: ModelContext) throws {
        context.delete(location)
        try context.save()
    }

    private func fetchCachedEntry(for query: String, context: ModelContext) throws -> CachedWeather? {
        let descriptor = FetchDescriptor<CachedWeather>(
            predicate: #Predicate<CachedWeather> { $0.query == query }
        )
        return try context.fetch(descriptor).first
    }

    private func updateCache(
        query: String,
        response: WeatherResponse,
        existing: CachedWeather?,
        context: ModelContext
    ) {
        guard let jsonData = try? JSONEncoder().encode(response) else { return }

        if let entry = existing {
            entry.jsonData  = jsonData
            entry.fetchedAt = Date()
        } else {
            context.insert(CachedWeather(query: query, jsonData: jsonData))
        }
        try? context.save()
    }
}
