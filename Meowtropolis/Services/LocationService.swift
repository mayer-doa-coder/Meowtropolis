import Foundation
import CoreLocation

final class LocationService: NSObject {
    typealias TestLocationRequestHandler = (@escaping (Result<CLLocationCoordinate2D, Error>) -> Void) -> Void

    enum LocationServiceError: LocalizedError {
        case permissionDenied
        case locationUnavailable

        var errorDescription: String? {
            switch self {
            case .permissionDenied:
                return "Location permission denied."
            case .locationUnavailable:
                return "Current location is unavailable."
            }
        }
    }

    private let locationManager = CLLocationManager()
    private let testAuthorizationStatus: CLAuthorizationStatus?
    private let testLocationRequestHandler: TestLocationRequestHandler?
    private var completion: ((Result<CLLocationCoordinate2D, Error>) -> Void)?

    init(
        testAuthorizationStatus: CLAuthorizationStatus? = nil,
        testLocationRequestHandler: TestLocationRequestHandler? = nil
    ) {
        self.testAuthorizationStatus = testAuthorizationStatus
        self.testLocationRequestHandler = testLocationRequestHandler
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
    }

    func authorizationStatus() -> CLAuthorizationStatus {
        testAuthorizationStatus ?? locationManager.authorizationStatus
    }

    func getCurrentLocation(
        completion: @escaping (Result<CLLocationCoordinate2D, Error>) -> Void
    ) {
        print("[LocationService] Requesting location")

        self.completion = completion

        if let testLocationRequestHandler {
            testLocationRequestHandler { [weak self] result in
                self?.complete(with: result)
            }
            return
        }

        let status = authorizationStatus()

        switch status {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.requestLocation()
        case .denied, .restricted:
            complete(with: .failure(LocationServiceError.permissionDenied))
        @unknown default:
            complete(with: .failure(LocationServiceError.locationUnavailable))
        }
    }

    private func complete(with result: Result<CLLocationCoordinate2D, Error>) {
        let currentCompletion = completion
        completion = nil

        DispatchQueue.main.async {
            switch result {
            case let .success(coordinate):
                print("[LocationService] Success: \(coordinate.latitude),\(coordinate.longitude)")
            case let .failure(error):
                print("[LocationService] Error: \(error.localizedDescription)")
            }
            currentCompletion?(result)
        }
    }
}

extension LocationService: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            manager.requestLocation()
        case .denied, .restricted:
            complete(with: .failure(LocationServiceError.permissionDenied))
        case .notDetermined:
            break
        @unknown default:
            complete(with: .failure(LocationServiceError.locationUnavailable))
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let coordinate = locations.last?.coordinate else {
            complete(with: .failure(LocationServiceError.locationUnavailable))
            return
        }

        complete(with: .success(coordinate))
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        complete(with: .failure(error))
    }
}
