import Foundation
import CoreLocation
import GooglePlaces

final class PlacesService {
    typealias TestSearchHandler = (PlaceSearchRequest, @escaping (Result<[Place], Error>) -> Void) -> Void

    private let placesClient: GMSPlacesClient
    private let testSearchHandler: TestSearchHandler?

    init(
        placesClient: GMSPlacesClient = GMSPlacesClient.shared(),
        testSearchHandler: TestSearchHandler? = nil
    ) {
        self.placesClient = placesClient
        self.testSearchHandler = testSearchHandler
    }

    func searchPlaces(
        request: PlaceSearchRequest,
        completion: @escaping (Result<[Place], Error>) -> Void
    ) {
        let cleanedQuery = request.query.trimmingCharacters(in: .whitespacesAndNewlines)
        print("[PlacesService] Searching: \"\(cleanedQuery)\"")

        if let testSearchHandler {
            testSearchHandler(request, completion)
            return
        }

        guard !cleanedQuery.isEmpty else {
            print("[PlacesService] Success: 0 results")
            completion(.success([]))
            return
        }

        let executeSearch = {
            let filter = GMSAutocompleteFilter()

            if let latitude = request.latitude, let longitude = request.longitude {
                filter.origin = CLLocation(latitude: latitude, longitude: longitude)
            }

            self.placesClient.findAutocompletePredictions(
                fromQuery: cleanedQuery,
                filter: filter,
                sessionToken: nil
            ) { predictions, error in
                if let error {
                    print("[PlacesService] Error: \(error.localizedDescription)")
                    completion(.failure(error))
                    return
                }

                let predictionList = predictions ?? []

                guard !predictionList.isEmpty else {
                    print("[PlacesService] Success: 0 results")
                    completion(.success([]))
                    return
                }

                self.fetchPlaces(predictions: predictionList, completion: completion)
            }
        }

        if Thread.isMainThread {
            executeSearch()
        } else {
            DispatchQueue.main.async {
                executeSearch()
            }
        }
    }

    private func fetchPlaces(
        predictions: [GMSAutocompletePrediction],
        completion: @escaping (Result<[Place], Error>) -> Void
    ) {
        let placeFields: GMSPlaceField = [.placeID, .name, .formattedAddress, .coordinate, .rating, .types]

        let group = DispatchGroup()
        var mappedPlaces: [Place] = []
        var firstError: Error?

        for prediction in predictions {
            group.enter()

            placesClient.fetchPlace(
                fromPlaceID: prediction.placeID,
                placeFields: placeFields,
                sessionToken: nil
            ) { place, error in
                defer { group.leave() }

                if let error {
                    if firstError == nil {
                        firstError = error
                    }
                    return
                }

                guard let place else {
                    return
                }

                mappedPlaces.append(self.mapPlace(place))
            }
        }

        group.notify(queue: .main) {
            if !mappedPlaces.isEmpty {
                print("[PlacesService] Success: \(mappedPlaces.count) results")
                completion(.success(mappedPlaces))
                return
            }

            if let firstError {
                print("[PlacesService] Error: \(firstError.localizedDescription)")
                completion(.failure(firstError))
                return
            }

            print("[PlacesService] Success: 0 results")
            completion(.success([]))
        }
    }

    private func mapPlace(_ place: GMSPlace) -> Place {
        Place(
            id: place.placeID ?? UUID().uuidString,
            name: place.name ?? "Unknown Place",
            address: place.formattedAddress ?? "",
            latitude: place.coordinate.latitude,
            longitude: place.coordinate.longitude,
            rating: place.rating > 0 ? place.rating : nil,
            types: place.types ?? []
        )
    }
}
