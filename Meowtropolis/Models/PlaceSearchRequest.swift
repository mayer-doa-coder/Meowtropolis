import Foundation

struct PlaceSearchRequest: Codable {
    let query: String
    let latitude: Double?
    let longitude: Double?
}
