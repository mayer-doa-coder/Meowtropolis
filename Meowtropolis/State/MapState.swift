import Foundation
import Combine
import CoreLocation

enum MapPermissionState {
    case needed
    case denied
    case requesting
    case granted
    case unavailable
}

final class MapState: ObservableObject {
    @Published var isLoading: Bool = false
    @Published var places: [Place] = []
    @Published var errorMessage: String?
    @Published var currentCoordinate: CLLocationCoordinate2D?
    @Published var selectedPlace: Place?
    @Published var permissionState: MapPermissionState = .needed
    @Published var lastQuery: String = ""

    var isEmpty: Bool {
        !isLoading && errorMessage == nil && places.isEmpty
    }

    private let locationService: LocationService
    private let placesService: PlacesService

    init(
        locationService: LocationService = LocationService(),
        placesService: PlacesService = PlacesService()
    ) {
        self.locationService = locationService
        self.placesService = placesService
        self.permissionState = mapPermissionState(from: locationService.authorizationStatus())
    }

    func searchPlaces(query: String) {
        let cleanedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !cleanedQuery.isEmpty else {
            isLoading = false
            places = []
            errorMessage = nil
            selectedPlace = nil
            lastQuery = ""
            print("[MapState] Empty result")
            return
        }

        isLoading = true
        places = []
        errorMessage = nil
        selectedPlace = nil
        lastQuery = cleanedQuery
        permissionState = .requesting
        UserHistoryService.shared.recordCurrentUser(
            category: .map,
            action: "Searched nearby places",
            details: cleanedQuery
        )

        print("[MapState] Starting search")

        locationService.getCurrentLocation { [weak self] locationResult in
            guard let self else {
                return
            }

            var request = PlaceSearchRequest(query: cleanedQuery, latitude: nil, longitude: nil)

            switch locationResult {
            case let .success(coordinate):
                self.currentCoordinate = coordinate
                self.permissionState = .granted
                request = PlaceSearchRequest(
                    query: cleanedQuery,
                    latitude: coordinate.latitude,
                    longitude: coordinate.longitude
                )
                print("[MapState] Using location: \(coordinate.latitude),\(coordinate.longitude)")
            case let .failure(error):
                if self.isPermissionDenied(error) {
                    self.permissionState = .denied
                } else {
                    self.permissionState = self.mapPermissionState(from: self.locationService.authorizationStatus())
                    if self.permissionState == .granted {
                        self.permissionState = .unavailable
                    }
                }
                print("[MapState] Location unavailable, searching without bias: \(error.localizedDescription)")
            }

            self.placesService.searchPlaces(request: request) { [weak self] result in
                guard let self else {
                    return
                }

                DispatchQueue.main.async {
                    self.isLoading = false

                    switch result {
                    case let .success(loadedPlaces):
                        self.errorMessage = nil
                        self.places = loadedPlaces
                        self.selectedPlace = nil

                        if loadedPlaces.isEmpty {
                            print("[MapState] Empty result")
                        } else {
                            print("[MapState] Loaded \(loadedPlaces.count) places")
                        }

                    case let .failure(error):
                        self.places = []
                        self.selectedPlace = nil
                        self.errorMessage = error.localizedDescription
                        print("[MapState] Error: \(error.localizedDescription)")
                    }
                }
            }
        }
    }

    func requestLocationPermission() {
        permissionState = .requesting
        locationService.getCurrentLocation { [weak self] result in
            guard let self else {
                return
            }

            switch result {
            case let .success(coordinate):
                self.currentCoordinate = coordinate
                self.permissionState = .granted
                print("[MapState] Using location: \(coordinate.latitude),\(coordinate.longitude)")
            case let .failure(error):
                if self.isPermissionDenied(error) {
                    self.permissionState = .denied
                } else {
                    self.permissionState = self.mapPermissionState(from: self.locationService.authorizationStatus())
                    if self.permissionState == .granted {
                        self.permissionState = .unavailable
                    }
                }
                print("[MapState] Error: \(error.localizedDescription)")
            }
        }
    }

    func selectPlace(_ place: Place?) {
        selectedPlace = place
        if let place {
            UserHistoryService.shared.recordCurrentUser(
                category: .map,
                action: "Viewed place details",
                details: place.name
            )
        }
    }

    private func isPermissionDenied(_ error: Error) -> Bool {
        guard let locationError = error as? LocationService.LocationServiceError else {
            return false
        }

        return locationError == .permissionDenied
    }

    private func mapPermissionState(from status: CLAuthorizationStatus) -> MapPermissionState {
        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
            return .granted
        case .denied, .restricted:
            return .denied
        case .notDetermined:
            return .needed
        @unknown default:
            return .unavailable
        }
    }
}
