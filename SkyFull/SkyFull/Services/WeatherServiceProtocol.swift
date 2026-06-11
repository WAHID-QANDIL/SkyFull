import Foundation

protocol WeatherServiceProtocol {
    func fetchForecast(query: String) async throws -> WeatherResponse
    func searchLocations(query: String) async throws -> [SearchResult]
}
