import Foundation

final class WeatherService: WeatherServiceProtocol {

    private let apiKey = "231c6884a86f4b86b7205729261106"
    private let base   = "https://api.weatherapi.com/v1"


    func fetchForecast(query: String) async throws -> WeatherResponse {
        let url = try buildURL(
            path: "/forecast.json",
            params: ["key": apiKey, "q": query, "days": "3", "aqi": "yes", "alerts": "no"]
        )
        return try await decode(from: url)
    }

    func searchLocations(query: String) async throws -> [SearchResult] {
        let url = try buildURL(path: "/search.json",
                               params: ["key": apiKey, "q": query])
        return try await decode(from: url)
    }

    private func buildURL(path: String, params: [String: String]) throws -> URL {
        var comps = URLComponents(string: base + path)!
        comps.queryItems = params.map { URLQueryItem(name: $0.key, value: $0.value) }
        guard let url = comps.url else { throw WeatherError.invalidURL }
        return url
    }

    private func decode<T: Decodable>(from url: URL) async throws -> T {
        let (data, response) = try await URLSession.shared.data(from: url)
        guard let http = response as? HTTPURLResponse,
              (200...299).contains(http.statusCode) else {
            throw WeatherError.serverError((response as? HTTPURLResponse)?.statusCode ?? -1)
        }
        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            throw WeatherError.decodingError(error)
        }
    }
}


enum WeatherError: LocalizedError {
    case invalidURL
    case serverError(Int)
    case decodingError(Error)

    var errorDescription: String? {
        switch self {
        case .invalidURL:            return "Invalid URL."
        case .serverError(let c):   return "Server error (\(c)). Check your API key."
        case .decodingError(let e): return "Decoding failed: \(e.localizedDescription)"
        }
    }
}
