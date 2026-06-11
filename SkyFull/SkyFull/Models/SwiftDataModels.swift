import Foundation
import SwiftData

@Model
final class CachedWeather {

    @Attribute(.unique) var query: String
    var jsonData: Data
    var fetchedAt: Date

    init(query: String, jsonData: Data) {
        self.query     = query
        self.jsonData  = jsonData
        self.fetchedAt = Date()
    }
    var isStale: Bool {
        Date().timeIntervalSince(fetchedAt) > 1_800
    }
}

@Model
final class SavedLocationModel {

    var name: String
    var country: String
    var lat: Double
    var lon: Double
    var addedAt: Date

    init(name: String, country: String, lat: Double, lon: Double) {
        self.name    = name
        self.country = country
        self.lat     = lat
        self.lon     = lon
        self.addedAt = Date()
    }
    var queryString: String { "\(lat),\(lon)" }
}
