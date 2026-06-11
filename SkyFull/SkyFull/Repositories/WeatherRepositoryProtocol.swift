import Foundation
import SwiftData

protocol WeatherRepositoryProtocol {

    func fetchForecast(query: String, context: ModelContext) async throws -> WeatherResponse
    func searchLocations(query: String) async throws -> [SearchResult]

    func fetchSavedLocations(context: ModelContext) throws -> [SavedLocationModel]
    func addLocation(_ result: SearchResult, context: ModelContext) throws
    func removeLocation(_ location: SavedLocationModel, context: ModelContext) throws
}
