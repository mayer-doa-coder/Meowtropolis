import Foundation
import GoogleMaps
import GooglePlaces

/// Handles one-time setup for Google Maps and Google Places SDKs.
final class MapsService {
    static let shared = MapsService()

    private let apiKeyInfoKey = "GOOGLE_MAPS_API_KEY"
    private var hasConfigured = false
    var isPlacesConfigured: Bool { hasConfigured }

    private init() {}

    func configure() {
        guard !hasConfigured else {
            return
        }

        guard let apiKey = Bundle.main.object(forInfoDictionaryKey: apiKeyInfoKey) as? String,
              !apiKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            print("[MapsService] Missing GOOGLE_MAPS_API_KEY in Info.plist. Maps setup skipped.")
            return
        }

        let didInitializeMaps = GMSServices.provideAPIKey(apiKey)
        let didInitializePlaces = GMSPlacesClient.provideAPIKey(apiKey)

        if !didInitializeMaps {
            print("[MapsService] Google Maps SDK initialization failed. Check API key and SDK setup.")
        }

        if !didInitializePlaces {
            print("[MapsService] Google Places SDK initialization failed. Check API key and API enablement.")
        }

        if didInitializeMaps && didInitializePlaces {
            hasConfigured = true
            print("[MapsService] Google Maps and Places SDK initialized successfully.")
        }
    }
}
